extends "res://items/item.gd"

## Nodes
onready var world = get_node("/root/World")


func picked_up(player):
	# if player.tirra && player.tirra.tirra_level >= 2:
	# 	return

	.picked_up(player)


func award_player(_player):
	# THe coords we want to reach
	var grid_position = world.get_grid_position(self.position)

	var tirra_path = pick_random_tirra()
	var tirra = load(tirra_path).instance()
	tirra.position = world.get_center_position_from_grid(grid_position)
	tirra.add_to_group(world.group_tirras)

	# No need to set network master to tirra,
	# will be owned by server by default
	var world_map = get_node("/root/World")
	world_map.add_child(tirra)

	# Put the egg above for the open animation
	var old_parent = self.get_parent()
	old_parent.remove_child(self)
	world_map.add_child(self)


func get_sub_class():
	return "Egg"


func pick_random_tirra():
	var colour = "blue"
	return "res://tirra/" + colour + "_tirra_0.tscn"
