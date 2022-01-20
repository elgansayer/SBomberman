extends "res://tirra/tirra.gd"


func action(player):
	if player.flying:
		return

	.action(player)
	jump(player)


func jump(player):
	# Turn off player animations
	player.frozen_movement = true
	player.frozen_animation = true

	var distance = 2 + current_tirra_level

	# Distance is 0 if we are not "moving"
	if player.current_animation_direction == "left" && player.motion.x == 0:
		distance = 0
	elif player.current_animation_direction == "right" && player.motion.x == 0:
		distance = 0
	elif player.current_animation_direction == "up" && player.motion.y == 0:
		distance = 0
	elif player.current_animation_direction == "down" && player.motion.y == 0:
		distance = 0

	# self.immortal = true
	var jump_gravity = 1000
	var custom_height = 1.15

	# print("Jumping ", distance)

	var target = player.position
	if distance != 0:
		var direction_table = world.direction_table
		var player_grid_pos = rider.grid_position
		var forward_vec = direction_table[player.current_animation_direction]
		target = player_grid_pos + (forward_vec * distance)
		player.launch(target, custom_height, jump_gravity)
	else:
		player.launch_to(target, custom_height, jump_gravity)


func get_sub_class():
	return "PinkTirra"
