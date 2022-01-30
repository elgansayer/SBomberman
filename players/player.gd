extends "res://scripts/throwable.gd"

# The player's current bomb power
# var max_explosion_length = 1;
var stat_virus = false
# The player's current rollerskates
var stat_skates = 1
# The player's current bomb power
var stat_power = 3
# Bombs that the player has
var stat_bombs = 99
# Does the player have a powerglove powerup?
var stat_power_glove = true
# Does the player have a powerglove powerup?
var stat_bomb_kicker = true

# The tirra we are riding
var tirra

# Is the player immune to damage?
var immortal setget immortal_set, immortal_get


func immortal_set(value):
	if value:
		var immortalVirus = load("res://players/behaviours/immortal.tscn").instance()
		self.add_child(immortalVirus)
	immortal = value


# Getter must return a value.
func immortal_get():
	return immortal


# What is the mover direction
var facing_direction setget facing_direction_set, facing_direction_get


# What is the mover direction
func facing_direction_set(value):
	facing_direction = value


# What is the mover direction
func facing_direction_get():
	return $Animator.facing_direction


# When the player first spawns
func _ready():
	add_to_group(world.group_players)
	$Mover.construct(self)
	$Animator.construct($Mover, $AnimatedSprite)


# Physcs update function
func _physics_process(delta):
	$Mover.process(delta)
	$Animator.process()

	# Debugging purposes
	set_player_name(str(str(floor(position.x)) + " " + str(floor(position.y))))
	set_grid_name(str(str(grid_position.x) + " " + str(grid_position.y)))
	grid_position = world.get_grid_position(position)


# Set the player's grid position
func set_grid_name(new_name):
	get_node("grid_label").set_text(new_name)
	$grid_label.modulate = Color(1, 1, 0, 1)


# Set the player's name
func set_player_name(new_name):
	get_node("label").set_text(new_name)


# Is the player trapped?
func is_trapped():
	var blocking_table = {"up": null, "down": null, "left": null, "right": null}

	grid_position = world.get_grid_position(position)
	var space_state = get_world_2d().direct_space_state

	var direction_table = world.direction_table
	var trapped = 0
	for direction in direction_table:
		var direction_vec = direction_table[direction]
		var grid_pos = grid_position + direction_vec
		var spot = world.get_center_position_from_grid(grid_pos)

		var blockingMask = world.blockingMask
		var result = space_state.intersect_point(spot, 1, [self], blockingMask, true, false)
		blocking_table[direction] = result

		if result.empty():
			return false

		trapped += 1

	# Trapped on all 4 sides
	return trapped == 4


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
	# print("killed")

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
func launch(grid_target, height_scale = 1.1, gravity_scale = GRAVITY_DEFAULT):
	# print("launching")
	$Mover.enabled = false
	var launch_vec = (grid_target - grid_position).normalized()
	var direction = world.vec_direction_table[launch_vec]
	var animation = "flying_" + direction
	$AnimationPlayer.play(animation)

	.launch(grid_target, height_scale, gravity_scale)


# The player landed from being thrown
func landed():
	.landed()
	# landed from got flying
	# self.frozen_movement = false
	# self.frozen_animation = false

	# $shape.disabled = false

	# if atslandedtach_to_tirra:
	# 	attach_to_tirra()
