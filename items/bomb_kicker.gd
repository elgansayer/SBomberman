extends "res://items/item.gd"


func award_player(player):
	player.stat_bomb_kicker = true


func get_class():
	return "ItemBombKicker"
