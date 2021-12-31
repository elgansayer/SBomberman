extends "res://items/item.gd"


func award_player(player):
	player.stat_power = player.stat_power + 1


func get_class():
	return "ItemPower"
