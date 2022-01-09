extends Area2D

export(String, "power", "power_glove", "bomb", "bomb_kicker", "rollerskate", "virus", "egg") var item_type
export(String, "pickup_special", "pickup", "pickup_powerglove", "got_virus", "pickup_egg") var pickup_sound

var picked = false
var correct_sound


func _ready():
	$AnimatedSprite.play(item_type)

	var sound_path = "res://sounds/items/" + pickup_sound + ".ogg"
	correct_sound = load(sound_path)


func _on_Timer_timeout():
	$AnimationPlayer.play("spin")


func play_sound():
	if !$AudioStreamPlayer2D.is_playing():
		$AudioStreamPlayer2D.stream = correct_sound
		$AudioStreamPlayer2D.play()


func award_player(_player):
	pass
	# player.stat_power = player.stat_power + 1
	# player.stat_bombs = player.stat_bombs + 1


func _on_Node2D_body_entered(body: Node):

	if body.get_class() == "Player":
		if picked:
			return

		picked = true

		play_sound()
		award_player(body)
		$AnimationPlayer.play("picked_up")


func explode():
	$AnimationPlayer.play("exploded")


func get_class():
	return "Item"
