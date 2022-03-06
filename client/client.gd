extends Node2D

func _ready():
    get_tree().connect("network_peer_connected", self, "_player_connected")
    get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
    get_tree().connect("connected_to_server", self, "_connected_ok")
    get_tree().connect("connection_failed", self, "_connected_fail")
    get_tree().connect("server_disconnected", self, "_server_disconnected")

func _connected_ok():
    pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected():
    pass # Server kicked us; show error and abort.

func _connected_fail():
    pass # Could not even connect to server; abort.
