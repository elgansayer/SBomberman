extends "res://tirra/tirra.gd"


func action(player):
	.action(player)
	kick_bomb()


func kick_bomb():
	print("kick_bomb ", rider.current_animation_direction)
	var direction_table = world.direction_table
	var player_grid_pos = rider.grid_position
	var forward_vec = direction_table[rider.current_animation_direction]
	var forward_grid_position = player_grid_pos + forward_vec
	var bombs = get_tree().get_nodes_in_group("bombs")
	print("forward_grid_position ", forward_grid_position)
	print("rider ", player_grid_pos)

	var distance = 3 + 2
	for bomb in bombs:
		if bomb.grid_position == forward_grid_position:
			print("bomb found at ", bomb.grid_position)
			var target = player_grid_pos + (forward_vec * distance)
			print("target ", target)
			print("bomb ", bomb)
			bomb.launch(target)
			return

func get_class():
	return "BlueTirra"
