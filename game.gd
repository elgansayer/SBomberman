extends Node

# Names for remote players in id:name:character format.
var players: Array = []

# The current world
var world: Node = null


func begin_game() -> void:
	# Add a world
	self.load_world()
	self.spawn_players()
	# self.start_game()


func add_player(playerInfo) -> void:
	self.players.append(playerInfo)


func remove_player(player) -> void:
	players.erase(player)


func spawn_players() -> void:
	var spawn_points: Array = self.world.get_node("SpawnPoints").get_children()

	for p in range(0, self.players.size()):
		var player = self.players[p]
		var spawn_point = spawn_points[p]
		self.spawn_player(player, spawn_point)


func spawn_player(player_info: Dictionary, spawn_point: Position2D) -> void:
	var player_id = player_info["id"]
	var player_name = player_info["name"]
	# var player_character = player_info["scene"]

	var player_scene = load("res://players/player.tscn")

	var player = player_scene.instance()
	world.get_node("Players").add_child(player)

	# Use unique ID as node name.
	player.set_player_label(player_name)
	player.set_name(str(player_id))

	player.position = spawn_point.position
	#set unique id as master.
	# player.set_network_master(p_id)


func load_world() -> void:
	get_tree().set_pause(true)

	# var loadingWorld = worlds

	self.world = load("res://world.tscn").instance()
	get_tree().get_root().add_child(self.world)
	# #get_tree().change_scene("res://world.tscn")

	var w = get_tree().get_root().get_node("World")
	var test = get_node("/root/World")

	print(test)
	print(w)


func start_game():
	get_tree().set_pause(false)  # Unpause and unleash the game!
