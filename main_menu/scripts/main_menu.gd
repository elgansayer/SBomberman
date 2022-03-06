extends Control

@export var loading_scene = null

func add_myself():
	var my_network_id = get_tree().get_network_unique_id()
	var playerInfo = {"id": my_network_id, "name": "Elgan", "scene": "none"}

	Game.add_player(playerInfo)


func _on_btn_host_game_pressed():
	var loading = loading_scene.instantiate()
	var root = get_tree().get_root()

	self.visible = false
	root.add_child(loading)

	Server.host_game()
	self.add_myself()

	root.remove_child(self)
	Game.begin_game()
	root.remove_child(loading)
