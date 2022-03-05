extends Control

@export var loading_scene: Resource = null


func _ready() -> void:
	OS.set_window_maximized(true)


func add_myself():
	var my_network_id = get_tree().get_network_unique_id()
	var playerInfo = {"id": my_network_id, "name": "Elgan", "scene": "none"}

	Game.add_player(playerInfo)


func _on_btn_host_pressed() -> void:
	var loading = loading_scene.instance()
	var root = get_tree().get_root()

	self.visible = false
	root.add_child(loading)
	# root.add_child(server)

	Server.host_game()
	self.add_myself()

	root.remove_child(self)

	Game.begin_game()

	root.remove_child(loading)
