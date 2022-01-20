extends "res://items/item.gd"


func award_player(player):
	player.got_virus()


func get_class():
	return "Virus"
