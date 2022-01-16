extends "res://tirra/tirra.gd"


func action(player):
	.action(player)
	kick_bomb(player)


func kick_bomb(player):
	var direction_table = world.direction_table
	var player_grid_pos = player.grid_position
	var forward_vec = direction_table[player.current_animation_direction]
	var forward_grid_position = player_grid_pos + forward_vec
	var bombs = get_tree().get_nodes_in_group("bombs")

	var distance = 3 + current_tirra_level
	for bomb in bombs:
		if bomb.grid_position == forward_grid_position:
			var target = player_grid_pos + (forward_vec * distance)
			bomb.launch(target)
