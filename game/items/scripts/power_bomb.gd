extends "res://game/items/item.gd"


func award_player(player):
	player.stat_power_glove = true


func get_class():
	return "ItemPowerBomb"
