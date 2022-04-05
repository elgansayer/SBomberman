extends Node2D

@export var anim_player_path: NodePath
var anim_player: AnimationPlayer

func _ready():
	anim_player = get_node(anim_player_path)
	
func _on_timer_timeout():
	anim_player.play("train")
	
