extends Node2D

@export var anim_player_path: NodePath

func _on_timer_timeout():
	get_node(anim_player_path).play("train")
	
