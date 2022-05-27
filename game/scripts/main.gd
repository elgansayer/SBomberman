extends Node

# Names for remote players in id:name:character format.
var players: Array = []

func _ready():
	self.begin_game()

func begin_game() -> void:	
	# Add a world
	self.load_world()

func world_loaded() -> void:
	# self.spawn_players()
	self.start_game()
	
func add_player(playerInfo) -> void:
	self.players.append(playerInfo)

func remove_player(player) -> void:
	players.erase(player)

func spawn_players() -> void:
	print("spawn_players")
	
	var world = get_tree().get_root().get_node("World")
	var spawn_points: Array = world.get_node("SpawnPoints").get_children()

	for p in range(0, self.players.size()):
		var player = self.players[p]
		var spawn_point = spawn_points[p]
		self.spawn_player(world, player, spawn_point)


func spawn_player(world, player_info: Dictionary, spawn_point: Position2D) -> void:
	var player_id = player_info["id"]
	var player_name = player_info["name"]
	# var player_character = player_info["scene"]

	var player_scene = load("res://game/players/player.tscn")

	var player = player_scene.instance()
	world.get_node("Players").add_child(player)

	# Use unique ID as node name.
	player.set_player_label(player_name)
	player.set_name(str(player_id))

	player.position = spawn_point.position
	spawn_point.used = true

	# Set unique id as master.
	# player.set_network_master(p_id)

	# world.get_node("SpawnPoints").remove_child(spawn_point)
	# spawn_point.queue_free()

	
func load_world() -> void:
	get_tree().set_pause(true)
	get_tree().change_scene("res://game/world.tscn")

	
func start_game():
	# Unpause and unleash the game!
	get_tree().set_pause(false)  
