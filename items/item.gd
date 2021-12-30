extends Area2D

var picked = false

func award_player(player):
	player.stat_power = player.stat_power + 1
	player.stat_bombs = player.stat_bombs + 1

func _on_Node2D_body_entered(body: Node):
	if body.get_class() == "Player":
		if picked:
			return
		
		picked = true

		award_player(body)
		$AnimationPlayer.play("picked_up")


func explode():
	$AnimationPlayer.play("exploded")


func get_class():
	return "Item"
