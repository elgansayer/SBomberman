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
var bomb_index = 0
var dead = false  # Is the player dead for good?

# Position of the player in the world tilemap
var grid_position = Vector2()

var collision_exceptions = []  # List of collision exceptions (typically bomb just dropped)

# func _ready():
# 	add_to_group("players")


# Use sync because it will be called everywhere
remotesync func setup_bomb(bomb_name, player, by_who):
	var grid_size = 32
	var position = player.position
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

	var bomb = preload("res://bomb/bomb.tscn").instance()
	bomb.set_name(bomb_name)  # Ensure unique name for the bomb

	bomb.position = bomb_pos
	bomb.from_player = by_who
	bomb.player_owner = player

	print("Plating bomb at " + str(grid_pos))
	# No need to set network master to bomb, will be owned by server by default
	get_node("/root/World/Bombs").add_child(bomb)


func _physics_process(_delta):
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

		if stunned:
			bombing = false
			motion = Vector2()

		if bombing and not prev_bombing:
			var bomb_name = String(get_name()) + str(bomb_index)
			bomb_index += 1
			rpc("setup_bomb", bomb_name, self, get_tree().get_network_unique_id())

		prev_bombing = bombing

		rset("puppet_motion", motion)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		motion = puppet_motion

	var is_new_anim = get_animation_name(motion)

	grid_position = get_grid_position(position)

	# if stunned:
	# 	new_anim = "stunned"
	set_player_name(str(str(floor(position.x)) + " " + str(floor(position.y))))
	set_grid_name(str(str(grid_position.x) + " " + str(grid_position.y)))

	if is_new_anim:
		var animatedSprite = get_node("AnimatedSprite")
		animatedSprite.flip_h = flipped_h
		animatedSprite.play(current_anim)

	# FIXME: Use move_and_slide
	move_and_slide(motion * MOTION_SPEED)
	if not is_network_master():
		puppet_pos = position  # To avoid jitter


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
		flipped_h = false
		current_direction = "left"
	elif motion.x > 0:
		flipped_h = true
		current_direction = "left"

	var new_anim = current_motion + "_" + current_direction
	var is_new_anim = current_anim != new_anim
	current_anim = new_anim
	return is_new_anim


puppet func killed():
	$AnimatedSprite.play("explode")	
	stunned = true


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
	
