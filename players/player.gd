extends "res://scripts/throwable.gd"

const MOTION_SPEED = 200.0
const time_has_virus = 5.0
const time_has_immortal = 3.0
## Nodes

#
# onready var screen_size = get_viewport_rect().size

# Position of player in the world on the network
# puppet var puppet_pos = Vector2()
# Motion of player in the world on the network
# puppet var puppet_motion = Vector2()

export var stunned = false

var blocking_table = {"up": null, "down": null, "left": null, "right": null}

# What is the current animationm
var current_animation = "standing_down"
# The animation to play on the tirra
# var current_tirra_animation = "standing_down"
# What is the current direction of the player?
var current_animation_direction = "down"
# Current motion description of the player
var current_animation_motion = "walk"

var immortal setget immortal_set, immortal_get


func immortal_set(value):
	immortal = value
	if value:
		$FlashTimer.start()
		$ImmortalTimer.set_wait_time(time_has_immortal)
		$ImmortalTimer.start()
	else:
		$FlashTimer.stop()
		$ImmortalTimer.stop()
		$AnimatedSprite.self_modulate = Color(1, 1, 1)
		set_white(0)


# Getter must return a value.
func immortal_get():
	return immortal


# The tirra we are riding
var current_tirra
var riding = false
var process_got_egg = false
var egg_position = Vector2.ZERO

var white_shader = false

# Previously bombing
var prev_bombing = false
# Previously doing an action
var prev_action = false
# Are we using power glove, Do we have a bomb?
var power_glove_bomb = null

# Track how many bombs planted
var bomb_index = 0
# Is the player dead for good?
var dead = false

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
var stat_virus = false
# The player's current rollerskates
var stat_skates = 1
# The player's current bomb power
var stat_power = 0
# Bombs that the player has
var stat_bombs = 99
# Does the player have a powerglove powerup?
var stat_power_glove = true
# Does the player have a powerglove powerup?
var stat_bomb_kicker = true

# Position of the player in the world tilemap
# var grid_position = Vector2()
# List of collision exceptions (typically bomb just dropped)
var collision_exceptions = []


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
	bomb.connect("on_explode", self, "_on_Bomb_exploded")

	# No need to set network master to bomb, will be owned by server by default
	get_node("/root/World/Bombs").add_child(bomb)


func _on_Bomb_exploded(bomb):
	active_bombs.erase(bomb)


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

		# if stunned:
		# 	action = false
		# 	bombing = false
		# 	motion = Vector2()

		if bombing:
			try_plant_bomb()

		if action:
			if try_action():
				motion = Vector2()

		prev_action = action
		prev_bombing = bombing

		rset("puppet_motion", motion)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		motion = puppet_motion

	return motion


func _physics_process(_delta):
	# print("_physics_process player")

	var motion = Vector2()

	# Debugging purposes
	set_player_name(str(str(floor(position.x)) + " " + str(floor(position.y))))
	set_grid_name(str(str(grid_position.x) + " " + str(grid_position.y)))

	if process_got_egg:
		self.call_deferred("handle_got_egg")

	# Can we move?
	if !frozen_movement:
		motion = update_input()

		# Use move_and_slide
		move_and_slide(motion * MOTION_SPEED)
		if not is_network_master():
			puppet_pos = position  # To avoid jitter

		# Update the grid position
		grid_position = world.get_grid_position(position)

	# If we cannot update the animation
	if !frozen_animation:
		update_animation(motion)

		update_z_index()


func update_animation(motion):
	# Update the animation
	var anim_data = get_animation_dictionary(motion)
	var player_animtion = anim_data["animation"]

	var is_new_anim = player_animtion != current_animation

	# This is a new animation
	current_animation = player_animtion
	current_animation_direction = anim_data["direction"]
	current_animation_motion = anim_data["motion"]
	# current_tirra_animation = anim_data["animation"]

	# If we have a tirra update it's animation
	if current_tirra:
		var tirra_animation = anim_data["tirra"]
		current_tirra.update_animation(tirra_animation)
		update_position_on_tirra()

	if !is_new_anim:
		return

	# Animate the sprite
	var animatedSprite = get_node("AnimatedSprite")
	animatedSprite.play(current_animation)


func update_position_on_tirra():
	current_tirra.update_position_on_tirra(self)

	# if current_animation_direction == "up":
	# 	$AnimatedSprite.position = Vector2(0, -20)
	# elif current_animation_direction == "down":
	# 	$AnimatedSprite.position = Vector2(0, -20)
	# elif current_animation_direction == "left":
	# 	$AnimatedSprite.position = Vector2(13, -20)
	# elif current_animation_direction == "right":
	# 	$AnimatedSprite.position = Vector2(-13, -20)


func can_power_glove():
	for i in active_bombs.size():
		var bomb = active_bombs[-i - 1]
		if bomb.grid_position == world.get_grid_position(self.position):
			return bomb
	return null


func dizzy():
	frozen_movement = true
	frozen_animation = true
	$AnimationPlayer.play("dizzy")
	# var dizzy_sound = preload("res://sounds/dizzy.ogg")
	# $AudioStreamPlayer2D.stream = dizzy_sound
	# $AudioStreamPlayer2D.play()


func pglove_throw():
	var bomb = power_glove_bomb
	var bomb_global_pos = bomb.global_position

	self.remove_child(bomb)
	get_node("/root/World/Bombs").add_child(bomb)

	bomb.set_network_position(bomb_global_pos)
	bomb.position = bomb_global_pos

	var direction_table = world.direction_table

	# How far the bomb is thrown
	var distance = 3
	var direction_table_vec = direction_table[current_animation_direction] * distance
	var target_grid_position = Vector2(grid_position.x, grid_position.y) + direction_table_vec
	bomb.throw(target_grid_position)

	var animation = "pglove_pickup_" + current_animation_direction
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
	var animation = "pglove_pickup_" + current_animation_direction

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
	if riding:
		var z_index_table = {
			"up": 1,
			"down": 0,
			"left": 1,
			"right": 1,
		}

		self.z_index = z_index_table[current_animation_direction]
		return

	# For powerglove
	var z_index_table = {
		"up": 1,
		"down": 0,
		"left": 0,
		"right": 0,
	}

	self.z_index = z_index_table[current_animation_direction]


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
	var bomb_dict = bomb_position_table[current_animation_direction][frame]
	var bomb_position = bomb_dict["pos"]
	# var bomb_scale = bomb_dict["scale"]

	# # print(current_animation_direction)
	# # print(frame)
	# # print(bomb_position)
	# # print(power_glove_bomb.z_index)

	# if current_animation_direction == "up":
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
		return false

	# prev_action = true

	if riding && current_tirra:
		current_tirra.action(self)
		return false

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

	# The same as snap to grid
	var grid_pos = world.get_grid_position(position)
	var bomb_pos = world.get_center_position_from_grid(grid_pos)

	# Cant plant a bomb where there already is one
	var bombs = get_tree().get_nodes_in_group("bombs")
	for bomb in bombs:
		if bomb.grid_position == grid_pos || bomb.position == bomb_pos:
			return

	var bomb_name = String(get_name()) + str(bomb_index)
	bomb_index += 1

	rpc("setup_bomb", bomb_pos, bomb_name, self, get_tree().get_network_unique_id())


func get_animation_dictionary(motion):
	var animation_motion = get_animation_motion(motion)
	var animation_direction = get_animation_direction(motion)
	var anim_prefix = get_animation_prefix()
	var animation_override = ""

	if animation_direction == "":
		animation_direction = current_animation_direction

	if flying:
		animation_override = "flying"
		anim_prefix = ""
	elif riding:
		animation_override = "ride"
		anim_prefix = ""
	# Check if we are trapped
	elif is_trapped():
		animation_override = "trapped"
		animation_direction = ""
		anim_prefix = ""

	# var new_anim = ""
	# if animation_override != "":

	# else:
	# 	new_anim = anim_prefix + animation_motion + "_" + animation_direction
	var final_animation = animation_motion
	if animation_override != "":
		final_animation = animation_override

	var splitter = ""
	if animation_direction != "":
		splitter = "_"

	var new_animation = anim_prefix + final_animation + splitter + animation_direction
	var tirra_animation = anim_prefix + animation_motion + splitter + animation_direction

	# var new_anim = anim_prefix + animation_motion + "_" + animation_direction
	# var is_new_anim = current_animation != new_anim

	return {
		"animation": new_animation,
		"tirra": tirra_animation,
		"direction": animation_direction,
		"motion": animation_motion,
		# current_tirra_animation = current_animation,
	}

	# current_animation = new_anim
	# current_animation_direction = animation_direction
	# current_animation_motion = animation_motion
	# current_tirra_animation = current_animation

	# return is_new_anim


func get_animation_motion(motion):
	if motion.x != 0 || motion.y != 0:
		return "walk"
	else:
		return "standing"


func get_animation_prefix():
	if in_power_glove:
		return "pglove_"

	return ""


func get_animation_direction(motion):
	var direction = ""

	if motion.y < 0:
		direction = "up"
	elif motion.y > 0:
		direction = "down"
	elif motion.x < 0:
		direction = "left"
	elif motion.x > 0:
		direction = "right"

	return direction


puppet func killed():
	# set_physics_process(false)
	print("killed")

	if immortal:
		return

	if flying:
		return

	# If we are riding a tirra, we need to jump off of it
	if riding:
		# self.call_deferred("kill_tirra")
		kill_tirra()
		return

	$AnimatedSprite.play("explode")
	stunned = true
	dead = true


master func explode():
	call_deferred("killed")


func set_grid_name(new_name):
	get_node("grid_label").set_text(new_name)
	$grid_label.modulate = Color(1, 1, 0, 1)


func set_player_name(new_name):
	get_node("label").set_text(new_name)


func _ready():
	add_to_group("players")
	stunned = false
	puppet_pos = position
	grid_position = world.get_grid_position(position)


# Is the player trapped?
func is_trapped():
	grid_position = world.get_grid_position(position)
	var space_state = get_world_2d().direct_space_state

	var direction_table = world.direction_table
	var trapped = 0
	for direction in direction_table:
		var direction_vec = direction_table[direction]
		var grid_pos = grid_position + direction_vec
		var spot = world.get_center_position_from_grid(grid_pos)

		var result = space_state.intersect_point(spot, 1, [self], collision_mask, true, false)
		blocking_table[direction] = result

		if !result.empty():
			trapped += 1

	# Trapped on all 4 sides
	return trapped == 4


func get_class():
	return "Player"


func set_white(white_value):
	var mat = $AnimatedSprite.get_material()
	mat.set_shader_param("white_progress", white_value)


func _on_FlashTimer_timeout():
	if dead:
		return

	if immortal:
		var white_value = 0.7

		if self.white_shader:
			white_value = 0.0

		set_white(white_value)
		self.white_shader = !self.white_shader
		return

		# print("self.self_modulate", self.self_modulate)
	var change_color = Color(1, 1, 1)

	if $AnimatedSprite.self_modulate == Color(0, 0, 0):
		$AnimatedSprite.self_modulate = change_color
	else:
		$AnimatedSprite.self_modulate = Color(0, 0, 0)


func _on_endImmortalTimer_timeout():
	self.immortal = false


func _on_endVirusTimer_timeout():
	self.stat_virus = false
	$VirusTimer.stop()
	$FlashTimer.stop()
	$AnimatedSprite.self_modulate = Color(1, 1, 1)


func got_virus():
	$FlashTimer.start()
	self.stat_virus = true
	$VirusTimer.set_wait_time(time_has_virus)
	$VirusTimer.start()


func upgrade_tirra(egg_grid_position):
	# current_tirra.upgrade_tirra()
	# jump_from_tirra()

	riding = false
	reset_sprite_position()
	var old_tirra = current_tirra

	# Kill old tirra
	var next_tirra_path = old_tirra.get_next_tirra_path()
	old_tirra.queue_free()

	var tirra = load(next_tirra_path).instance()
	tirra.position = world.get_center_position_from_grid(egg_grid_position)
	tirra.add_to_group(world.group_tirras)
	# So we dont allow players to pick this up
	tirra.picked = true

	# No need to set network master to tirra, will be owned by server by default
	get_node("/root/World").add_child(tirra)

	current_tirra = tirra
	current_tirra.rider = self

	# self.immortal = true
	var jump_gravity = 1000
	var custom_height = 1.15
	self.launch(egg_grid_position, custom_height, jump_gravity)


func got_egg(egg_grid_position):
	egg_position = egg_grid_position

	# Just upgreade if we are already riding
	if riding && current_tirra && current_tirra.current_tirra_level < 3:
		upgrade_tirra(egg_position)
		return false
	elif riding:
		return false

	process_got_egg = true
	current_tirra = world.get_group_node_at(egg_grid_position, world.group_tirras)
	return true


func handle_got_egg():
	process_got_egg = false

	var jump_gravity = 1000
	var custom_height = 1.15
	# self.call_deferred("launch", egg_position, custom_height, jump_gravity)
	self.launch(egg_position, custom_height, jump_gravity)


func launch(grid_target, height_scale = 1.1, gravity_scale = GRAVITY_DEFAULT):
	print("launching")
	frozen_movement = true

	$shape.disabled = true
	.launch(grid_target, height_scale, gravity_scale)


func landed():
	.landed()
	print("landed")
	# landed from got flying
	self.frozen_movement = false
	self.frozen_animation = false

	$shape.disabled = false

	if current_tirra:
		attach_to_tirra()


func reset_sprite_position():
	$AnimatedSprite.position = Vector2(0, -12)


func kill_tirra():
	self.immortal = true

	print("kill_tirra")
	self.riding = false

	print("jump_from_tirra")
	reset_sprite_position()

	var jump_gravity = 1000
	var custom_height = 1.15
	self.launch(self.grid_position, custom_height, jump_gravity)

	# play exploding on the tirra
	var new_parent = current_tirra.get_parent()
	new_parent.remove_child(current_tirra)
	get_node("/root/World").add_child(current_tirra)
	current_tirra.position = world.get_center_position_from_grid(grid_position)

	current_tirra.explode()
	current_tirra = null


func attach_to_tirra():
	print("attach_to_tirra")
	riding = true
	current_tirra.position = Vector2(0, 0)
	current_tirra.z_as_relative = false

	# Let the tirra know we are riding
	current_tirra.rider = self

	var new_parent = current_tirra.get_parent()
	new_parent.remove_child(current_tirra)

	# No need to set network master to bomb, will be owned by server by default
	self.add_child(current_tirra)
