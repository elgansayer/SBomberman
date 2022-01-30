extends "res://tirra/tirra.gd"


func perform_action():
	# if player.flying:
	# 	return

	.perform_action()
	jump()


func jump():
	# Turn off player animations
	# rider.frozen_movement = true
	# $Animator.enabled = true

	var distance = 2 + tirra_level

	# Distance is 0 if we are not "moving"
	if $Animator.facing_direction == "left" && rider.motion.x == 0:
		distance = 0
	elif $Animator.facing_direction == "right" && rider.motion.x == 0:
		distance = 0
	elif $Animator.facing_direction == "up" && rider.motion.y == 0:
		distance = 0
	elif $Animator.facing_direction == "down" && rider.motion.y == 0:
		distance = 0

	var jump_gravity = 1000
	var custom_height = 1.15

	var target = rider.position
	if distance != 0:
		var direction_table = world.direction_table
		var rider_grid_pos = rider.grid_position
		var forward_vec = direction_table[$Animator.facing_direction]
		target = rider_grid_pos + (forward_vec * distance)
		rider.launch(target, custom_height, jump_gravity)
	else:
		rider.launch_to(target, custom_height, jump_gravity)


func get_sub_class():
	return "PinkTirra"
