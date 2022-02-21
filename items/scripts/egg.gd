extends "res://items/item.gd"

## Nodes
onready var world = get_node("/root/World")
export(Array, Resource) var tirras


func picked_up(player):
	# if player.tirra && player.tirra.tirra_level >= 2:
	# 	return

	.picked_up(player)


# func upgrade_tirra(player):
# 	if player.tirra && player.tirra.tirra_level >= player.tirra.TIRRA_LEVEL.big:
# 		return

# 	# Delete the old tirra and make a new one!
# 	var old_tirra = player.tirra

# 	var next_level = old_tirra.tirra_level + 1
# 	var tirra_path = (
# 		"res://tirra/tirra_"
# 		+ str(old_tirra.colour)
# 		+ "_"
# 		+ old_tirra.tirra_levels[next_level]
# 		+ ".tscn"
# 	)

# 	var tirra = load(tirra_path).instance()
# 	tirra.position = old_tirra.position
# 	tirra.add_to_group(world.group_tirras)

# 	# Remove the old tirra
# 	old_tirra.queue_free()

# 	# Set the new tirra
# 	tirra.attach_rider_to_tirra(player)


func award_player(player):
	# If the player has a tirra. Upgrade it.
	if player.tirra:
		player.tirra.upgrade_tirra(player)
	else:
		new_tirra()


func new_tirra():
	# THe coords we want to reach
	var grid_position = world.get_grid_position(self.position)

	var tirra_resource = pick_random_tirra()
	var tirra = tirra_resource.instance()
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
	var rand_index:int = randi() % tirras.size()	
	return tirras[rand_index]