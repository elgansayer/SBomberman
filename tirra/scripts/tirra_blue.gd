extends "res://tirra/scripts/tirra.gd"


func perform_action():
	.perform_action()
	kick_bomb()


func kick_bomb():
	var direction_table = world.direction_table
	var player_grid_pos = rider.grid_position
	var forward_vec = direction_table[$Animator.facing_direction]
	var forward_grid_position = player_grid_pos + forward_vec
	var bombs = get_tree().get_nodes_in_group("bombs")

	var distance = 3 + tirra_level
	var target = player_grid_pos + (forward_vec * distance)
	for bomb in bombs:
		if bomb.grid_position == forward_grid_position:
			bomb.launch(target)
			return


func get_class():
	return "BlueTirra"
