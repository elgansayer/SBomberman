extends KinematicBody2D
#"res://scripts/throwable.gd"

## Nodes
@onready var world = get_node("/root/World")

signal landed
#"res://players/behaviours/immortal.tscn"
@export(Resource) var immortal_scene

# The player's current bomb power
# var max_explosion_length = 1;
var stat_virus: bool = false
# The player's current rollerskates
var stat_skates = 1
# The player's current bomb power
var stat_power = 3
# Bombs that the player has
var stat_bombs = 99
# Does the player have a powerglove powerup?
var stat_power_glove = true
# Does the player have a powerglove powerup?
var stat_bomb_kicker = false

# The tirra we are riding
var tirra

# Is the player immune to damage?
var immortal setget immortal_set


func immortal_set(value):
	if value:
		var immortal_virus = immortal_scene.instance()
		self.add_child(immortal_virus)
	immortal = value


# What is the mover direction
var facing_direction setget , facing_direction_get


# What is the mover direction
func facing_direction_set(value):
	facing_direction = value


# What is the mover direction
func facing_direction_get():
	return $Animator.facing_direction


# When the player first spawns
func _ready():
	add_to_group(world.group_players)
	$Mover.construct(self, $Animator)
	$Animator.construct($Mover, $AnimatedSprite)


# Physcs update function
func _physics_process(delta):
	$Mover.process(delta)
	$Animator.process()

	# Debugging purposes
	# set_player_label(str(str(floor(position.x)) + " " + str(floor(position.y))))
	#set_grid_name(str(str(grid_position.x) + " " + str(grid_position.y)))


# Set the player's grid position
# func set_grid_name(new_name):
# 	get_node("grid_label").set_text(new_name)
# 	$grid_label.modulate = Color(1, 1, 0, 1)


# Set the player's name
func set_player_label(new_name):
	$Namelabel.set_text(new_name)


# Is the player trapped?
# func is_trapped():
# 	var blocking_table = {"up": null, "down": null, "left": null, "right": null}

# 	var space_state = get_world_2d().direct_space_state

# 	var direction_table = world.direction_table
# 	var trapped = 0
# 	for direction in direction_table:
# 		var direction_vec = direction_table[direction]
# 		var grid_pos = grid_position + direction_vec
# 		var spot = world.get_center_position_from_grid(grid_pos)

# 		var result = space_state.intersect_point(spot, 1, [self], world.blockingMask, true, false)
# 		blocking_table[direction] = result

# 		if result.empty():
# 			return false

# 		trapped += 1

# 	# Trapped on all 4 sides
# 	return trapped == 4


# When the player get hit by a moving object
func dizzy():
	#TODO: Move this to an ability
	$Mover.enabled = false
	$Animator.enabled = true
	$AnimationPlayer.play("dizzy")


# Name of the class
func get_class():
	return "Player"


# Update z index: TODO: Move to an ability
func update_z_index():
	# if riding:
	# 	var z_index_table = {
	# 		"up": 1,
	# 		"down": 0,
	# 		"left": 1,
	# 		"right": 1,
	# 	}

	# 	self.z_index = z_index_table[facing_direction]
	# 	return

	# For powerglove
	var z_index_table = {
		"up": 1,
		"down": 0,
		"left": 0,
		"right": 0,
	}

	# self.z_index = z_index_table[facing_direction]


puppet func killed():
	# set_physics_process(false)
	# #print("killed")

	# if immortal:
	# 	return

	# if flying:
	# 	return

	# # If we are riding a tirra, we need to jump off of it
	# if riding:
	# 	# self.call_deferred("kill_tirra")
	# 	kill_tirra()
	# 	return
	$AnimatedSprite.play("explode")
	# stunned = true
	# dead = true


# When the player dies
master func explode():
	call_deferred("killed")


# The player got a virus
func got_virus():
	var virus = load("res://players/behaviours/virus.tscn").instance()
	self.add_child(virus)


# Throw player through the air
# func launch(grid_target, height_scale = 1.1, gravity_scale = GRAVITY_DEFAULT):
# 	$Mover.enabled = false

# 	var direction = $Animator.facing_direction
# 	# if direction == "":
# 	# 	direction = "down"

# 	# var animation = "flying_" + direction
# 	# $AnimationPlayer.play(animation)

# 	var shadow = load("res://scenes/shadow.tscn").instance()
# 	world.add_child(shadow)
# 	var shadow_move_dir = world.direction_orientation[direction]
# 	shadow.constructor(self, shadow_move_dir)

# 	.launch(grid_target, height_scale, gravity_scale)


# The player landed from being thrown
func landed():
	.landed()
	emit_signal("landed")

	# landed from got flying
	# self.frozen_movement = false
	# self.frozen_animation = false
	# $Animator.enabled = true
	# $Mover.enabled = true

	# $shape.disabled = false

	# if atslandedtach_to_tirra:
	# 	attach_to_tirra()