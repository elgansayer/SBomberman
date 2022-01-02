extends KinematicBody2D

const MOTION_SPEED = 90.0

# Position of player in the world on the network
puppet var puppet_pos = Vector2()
# Motion of player in the world on the network
puppet var puppet_motion = Vector2()

export var stunned = false

# What is the current animationm
var current_anim = "standing_down"
# What is the current direction of the player?
var current_direction = "down"
# Is the animation flipped?
var flipped_h = false
# Current motion of the player
var current_motion = ""
var prev_bombing = false
var prev_action = false
var power_glove_bomb = null

# Track how many bombs planted
var bomb_index = 0
# Is the player dead for good?
var dead = false

var state_machine
var run_speed = 80

# The player's current bombs
# var active_bombs = 0
var active_bombs = []

# Is the playing carrying a bomb?
var in_power_glove = false

# If we are frozen, no movement is allows
var frozen_movement = false
# If we are froze, we cannot update the animation
var frozen_animation = false

# The player's current bomb power
# var max_explosion_length = 1;
# The player's current bomb power
var stat_power = 3
# Bombs that the player has
var stat_bombs = 11
# Does the player have a powerglove powerup?
var stat_power_glove = true
# Does the player have a powerglove powerup?
var stat_bomb_kicker = true

# Position of the player in the world tilemap
var grid_position = Vector2()

var collision_exceptions = []  # List of collision exceptions (typically bomb just dropped)

# func _ready():
# 	add_to_group("players")


# Use sync because it will be called everywhere
remotesync func setup_bomb(bomb_pos, bomb_name, player, by_who):
	var bomb = preload("res://bomb/bomb.tscn").instance()
	bomb.set_name(bomb_name)  # Ensure unique name for the bomb

	bomb.stat_power = player.stat_power
	bomb.position = bomb_pos
	bomb.from_player = by_who
	bomb.player_owner = player
	player.active_bombs.append(bomb)

	# Increment the bombs active and planted
	# active_bombs = active_bombs + 1
	bomb.connect("exploded", self, "_on_Bomb_exploded")

	# No need to set network master to bomb, will be owned by server by default
	get_node("/root/World/Bombs").add_child(bomb)


func _on_Bomb_exploded(bomb):
	active_bombs.erase(bomb)
	# bombs.remove(bomb)


func update_input():
	var motion = Vector2()

	if is_network_master():
		if Input.is_action_pressed("move_left"):
			motion += Vector2(-1, 0)
		if Input.is_action_pressed("move_right"):
			motion += Vector2(1, 0)
		if Input.is_action_pressed("move_up"):
			motion += Vector2(0, -1)
		if Input.is_action_pressed("move_down"):
			motion += Vector2(0, 1)

		var bombing = Input.is_action_pressed("set_bomb")
		var action = Input.is_action_pressed("action")

		if stunned:
			action = false
			bombing = false
			motion = Vector2()

		if bombing:
			try_plant_bomb()

		if action:
			if try_action():
				motion = Vector2()

		prev_bombing = bombing
		prev_action = action

		rset("puppet_motion", motion)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		motion = puppet_motion

	return motion


func _physics_process(_delta):
	var motion = Vector2()

	update_z_index()

	# Can we move?
	if !frozen_movement:
		motion = update_input()

	# If we cannot update the animation
	if frozen_animation:
		return

	# Update the animation
	var is_new_anim = get_animation_name(motion)
	grid_position = get_grid_position(position)

	# if stunned:
	# 	new_anim = "stunned"

	# Debugging purposes
	set_player_name(str(str(floor(position.x)) + " " + str(floor(position.y))))
	set_grid_name(str(str(grid_position.x) + " " + str(grid_position.y)))

	if is_new_anim:
		var animatedSprite = get_node("AnimatedSprite")
		# animatedSprite.flip_h = flipped_h
		animatedSprite.play(current_anim)

	# Use move_and_slide
	move_and_slide(motion * MOTION_SPEED)
	if not is_network_master():
		puppet_pos = position  # To avoid jitter


func can_power_glove():
	for i in active_bombs.size():
		var bomb = active_bombs[-i - 1]
		if bomb.grid_position == self.get_grid_position(self.position):
			return bomb
	return null


func pglove_throw():
	var bomb = power_glove_bomb
	var bomb_global_pos = bomb.global_position

	self.remove_child(bomb)
	get_node("/root/World/Bombs").add_child(bomb)

	bomb.set_network_position(bomb_global_pos)
	bomb.position = bomb_global_pos

	# bomb.velocity = Vector2(-100, -100)
	# bomb.move_and_collide(Vector2(-100, -100))
	var direction_table = {
		"up": Vector2(0, -1), "down": Vector2(0, 1), "left": Vector2(-1, 0), "right": Vector2(1, 0)
	}
	
	# How far the bomb is thrown
	var distance = 3
	var direction_table_vec = direction_table[current_direction] * distance
	var target_grid_position = Vector2(grid_position.x, grid_position.y) + direction_table_vec
	print("target_grid_position: " + str(target_grid_position))
	bomb.throw(target_grid_position)

	var animation = "pglove_pickup_" + current_direction
	$AnimatedSprite.play(animation, true)
	$AnimatedSprite.speed_scale = 2.0
	power_glove_bomb = null
	in_power_glove = false
	frozen_movement = false
	frozen_animation = false


func do_power_glove():
	if in_power_glove:
		pglove_throw()
		return

	var bomb = can_power_glove()
	if bomb == null:
		return

	in_power_glove = true
	frozen_movement = true
	frozen_animation = true

	# Stop the bomb from epxloding, change its animation
	bomb.paused = true
	var animation = "pglove_pickup_" + current_direction

	# Move the bomb per frame
	$AnimatedSprite.connect("frame_changed", self, "_on_PGlove_frame_changed")
	$AnimatedSprite.connect("animation_finished", self, "_on_PGlove_animation_finished")
	$AnimatedSprite.play(animation)

	var new_parent = bomb.get_parent()
	new_parent.remove_child(bomb)
	self.add_child(bomb)
	bomb.set_network_position(Vector2(0, 16))

	power_glove_bomb = bomb
	_on_PGlove_frame_changed()


func _on_PGlove_animation_finished():
	$AnimatedSprite.disconnect("frame_changed", self, "_on_PGlove_frame_changed")
	$AnimatedSprite.disconnect("animation_finished", self, "_on_PGlove_animation_finished")

	frozen_movement = false
	frozen_animation = false


func update_z_index():
	var z_index_table = {
		"up": 1,
		"down": 0,
		"left": 0,
		"right": 0,
	}

	# if current_direction == "up":
	# 	power_glove_bomb.z_index = -1
	# 	power_glove_bomb.z_as_relative = false

	# power_glove_bomb.z_index = 0
	# power_glove_bomb.z_as_relative = false
	self.z_index = z_index_table[current_direction]


func _on_PGlove_frame_changed():
	if !power_glove_bomb:
		return

	var bomb_position_table = {
		"up":
		{
			0:
			{
				"pos": Vector2(0, 0),
				"scale": Vector2(0.8, 0.8),
			},
			1:
			{
				"pos": Vector2(0, -8),
				"scale": Vector2(1.0, 1.0),
			},
			2:
			{
				"pos": Vector2(0, -20),
				"scale": Vector2(2.0, 2.0),
			}
		},
		"down":
		{
			0:
			{
				"pos": Vector2(0, 16),
				"scale": Vector2(0.8, 0.8),
			},
			1:
			{
				"pos": Vector2(0, -8),
				"scale": Vector2(1.0, 1.0),
			},
			2:
			{
				"pos": Vector2(0, -20),
				"scale": Vector2(2.0, 2.0),
			}
		},
		"left":
		{
			0:
			{
				"pos": Vector2(-10, 8),
				"scale": Vector2(0.8, 0.8),
			},
			1:
			{
				"pos": Vector2(-16, 0),
				"scale": Vector2(1.0, 1.0),
			},
			2:
			{
				"pos": Vector2(0, -24),
				"scale": Vector2(2.0, 2.0),
			}
		},
		"right":
		{
			0:
			{
				"pos": Vector2(10, 8),
				"scale": Vector2(0.8, 0.8),
			},
			1:
			{
				"pos": Vector2(16, 0),
				"scale": Vector2(1.0, 1.0),
			},
			2:
			{
				"pos": Vector2(0, -24),
				"scale": Vector2(2.0, 2.0),
			}
		}
	}

	var frame = $AnimatedSprite.frame
	var bomb_dict = bomb_position_table[current_direction][frame]
	var bomb_position = bomb_dict["pos"]
	# var bomb_scale = bomb_dict["scale"]

	# print(current_direction)
	# print(frame)
	# print(bomb_position)
	# print(power_glove_bomb.z_index)

	# if current_direction == "up":
	# 	power_glove_bomb.z_index = -1
	power_glove_bomb.z_as_relative = false

	# if current_direction == "up":
	# 	power_glove_bomb.z_index = -1
	# 	power_glove_bomb.z_as_relative = false

	# power_glove_bomb.z_index = 0
	# power_glove_bomb.z_as_relative = false
	# self.z_index = 1

	if is_network_master():
		power_glove_bomb.set_network_position(bomb_position)
	else:
		power_glove_bomb.position = bomb_position
		# power_glove_bomb.scale = bomb_scale


# Try and do an action
# return true if the player should not move
func try_action():
	if prev_action:
		return

	if stat_power_glove:
		return do_power_glove()

	return


func try_plant_bomb():
	# Can't plant bomb if we just tried,
	# Can't plant bomb if we are carrying a bomb
	# Cant plant a bomb if we exceeded bombs left
	# If we are frozen, we can't plant a bomb
	if (
		prev_bombing
		|| frozen_movement
		|| frozen_animation
		|| in_power_glove
		|| active_bombs.size() >= stat_bombs
	):
		return

	var grid_size = 32
	var grid_x = floor(position.x / grid_size)
	var grid_y = floor(position.y / grid_size)
	var half_grid = grid_size / 2
	var grid_pos = Vector2(grid_x, grid_y)
	var bomb_pos = Vector2(grid_x * grid_size + half_grid, grid_y * grid_size + half_grid)

	# Cant plant a bomb where there already is one
	var bombs = get_tree().get_nodes_in_group("bombs")
	for bomb in bombs:
		if bomb.grid_position == grid_pos || bomb.position == bomb_pos:
			return
	var bomb_name = String(get_name()) + str(bomb_index)
	bomb_index += 1

	# print("Plating bomb at " + str(grid_pos))
	rpc("setup_bomb", bomb_pos, bomb_name, self, get_tree().get_network_unique_id())


func get_animation_name(motion):
	if motion.x != 0 || motion.y != 0:
		current_motion = "walk"
	else:
		current_motion = "standing"

	if motion.y < 0:
		current_direction = "up"
	elif motion.y > 0:
		current_direction = "down"
	elif motion.x < 0:
		current_direction = "left"
	elif motion.x > 0:
		current_direction = "right"

	var animn_prefix = ""
	if in_power_glove:
		animn_prefix = "pglove_"

	var new_anim = animn_prefix + current_motion + "_" + current_direction
	var is_new_anim = current_anim != new_anim
	current_anim = new_anim
	return is_new_anim


puppet func killed():
	# set_physics_process(false)
	$AnimatedSprite.play("explode")
	stunned = true
	dead = true


master func exploded(_by_who):
	if stunned:
		return
	rpc("killed")  # Stun puppets
	killed()  # Stun master - could use sync to do both at once


master func explode():
	killed()  # Stun master - could use sync to do both at once


func set_grid_name(new_name):
	get_node("grid_label").set_text(new_name)
	$grid_label.modulate = Color(1, 1, 0, 1)


func set_player_name(new_name):
	get_node("label").set_text(new_name)


func _ready():
	state_machine = $AnimationTree.get("parameters/playback")
	add_to_group("players")
	stunned = false
	puppet_pos = position
	get_grid_position(position)


func get_grid_position(position):
	var grid_size = 32
	var grid_x = floor(position.x / grid_size)
	var grid_y = floor(position.y / grid_size)
	grid_position = Vector2(grid_x, grid_y)
	return grid_position


func get_class():
	return "Player"
