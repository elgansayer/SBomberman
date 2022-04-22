extends "res://game/items/item.gd"


func award_player(player):
	player.stat_bombs = player.stat_bombs + 1


func get_class():
	return "ItemBomb"
