# extends Node2D

# @export var loading_scene: Resource = null
# @export var menu_animator_path: NodePath

# func _ready() -> void:
# 	pass
# 	#OS.set_window_maximized(true)


# func add_myself():
# 	var my_network_id = get_tree().get_network_unique_id()
# 	var playerInfo = {"id": my_network_id, "name": "Elgan", "scene": "none"}

# 	Game.add_player(playerInfo)


# func _on_btn_host_game_pressed():
# 	var loading = loading_scene.instantiate()
# 	var root = get_tree().get_root()

# 	self.visible = false
# 	root.add_child(loading)

# 	Server.host_game()
# 	self.add_myself()

# 	root.remove_child(self)
# 	Game.begin_game()
# 	root.remove_child(loading)

# func _on_btn_battle_pressed():
# 	get_node("UILayer/MainMenu").visible = false	
# 	get_node("UILayer/BattleMenu").visible = true

# func _on_btn_back_pressed():
# 	get_node("UILayer/MainMenu").visible = true
# 	get_node("UILayer/BattleMenu").visible = false
		
# 	var menu_animator = get_node(menu_animator_path)
# 	var button_path = menu_animator.buttons[0]
# 	var btn = get_node("UILayer").get_node(button_path)
# 	# btn.grab_focus()
# 	menu_animator.swap_position()
