extends "res://items/item.gd"

## Nodes
onready var world = get_node("/root/World")


func _ready():
	$AnimatedSprite.play(item_type)
	pass


func play_sound():
	pass


func award_player(player):
	# THe coords we want to reach
	var grid_position = world.get_grid_position(self.position)

	var tirra = preload("res://tirra/tirra.tscn").instance()
	tirra.position = world.get_center_position_from_grid(grid_position)
	tirra.add_to_group(world.group_tirras)
	
	# No need to set network master to tirra, will be owned by server by default
	get_node("/root/World").add_child(tirra)

	# player.got_egg(grid_position)
	.award_player(player)

func get_class():
	return "Egg"
