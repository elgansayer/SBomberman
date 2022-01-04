extends "res://items/item.gd"


func award_player(player):
	player.stat_skates = player.stat_skates + 1


func get_class():
	return "Rollerskate"
