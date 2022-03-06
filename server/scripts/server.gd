extends Node2D

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 10567

# Max number of players.
const MAX_PEERS = 12

var peer = null

# Name for my player.
var player_name = "Bomerman"

# Names for remote players in id:name format.
var players = {}
var players_ready = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#get_tree().connect("network_peer_connected", self, "_player_connected")
	#get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

	#get_tree().connect("connected_to_server", self, "_connected_ok")
	#get_tree().connect("connection_failed", self, "_connected_fail")
	#get_tree().connect("server_disconnected", self, "_server_disconnected")


func _connected_ok():
	print("_connected_ok")
	pass  # Only called on clients, not server. Will go unused; not useful here.


func _server_disconnected():
	print("Player _server_disconnected")
	pass  # Server kicked us; show error and abort.


func _connected_fail():
	print("Player _connected_fail")
	pass  # Could not even connect to server; abort.


func _player_connected(id):
	print("Player connected:", id)
	# Called on both clients and server when a peer connects. Send my info to it.
	# rpc_id(id, "register_player", my_info)


func _player_disconnected(id):
	print("Player disconnected:", id)
	# player_info.erase(id)  # Erase player from info.


func host_game():
	peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	# multiplayer.set_network_peer(peer)
	# multiplayer.set_network_peer(peer)

func get_peer_latency(id):
	var peer = enet.get_peer(id)
	return peer.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)
