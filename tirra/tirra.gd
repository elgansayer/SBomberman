extends Area2D
# extends "res://items/item.gd"
# export(String, "pickup_egg") var pickup_sound

var picked = false
var correct_sound
var current_animation = "idle"
export(String, "blue", "red") var colour
export(int, "Baby", "Teen", "Adult") var current_tirra_level

## Nodes
onready var world = get_node("/root/World")
var tirra_owned = false

var grid_position setget grid_position_set, grid_position_get


func grid_position_set(value):
	grid_position = value


func grid_position_get():
	return world.get_grid_position(self.position)


func _ready():
	# Set up the tirra as a baby
	$AnimatedSprite.play("standing_down")

	# var sound_path = "res://sounds/items/" + pickup_sound + ".ogg"
	# correct_sound = load(sound_path)


# func upgrade_tirra():
# 	if current_tirra_level >= 3:
# 		return

# 	current_tirra_level = current_tirra_level + 1


func action(player):
	var animation = "action_" + player.current_animation_direction
	# update_animation(animation)
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play(animation)


func update_animation(animation_name):
	if current_animation == animation_name:
		return

	current_animation = animation_name
	# if !$AnimatedSprite.is_playing():
	$AnimatedSprite.play(animation_name)


func award_player(player):
	var tirra_grid_position = self.grid_position
	$Timer.stop()

	var got_egg = player.got_egg(tirra_grid_position)
	if !got_egg:
		# $AnimationPlayer.play("picked_up")
		queue_free()


func _on_Timer_timeout():
	$AnimationPlayer.play("spin")


func play_sound():
	if !$AudioStreamPlayer2D.is_playing():
		$AudioStreamPlayer2D.stream = correct_sound
		$AudioStreamPlayer2D.play()


func explode():
	$AnimationPlayer.play("explode")


func get_class():
	return "Tirra"


func _on_Tirra_body_entered(body: Node):
	print("_on_Tirra_body_entereds")

	if picked:
		return

	if body.get_class() == "Player":
		picked = true

		play_sound()
		call_deferred("award_player", body)


func get_next_tirra_path():
	print(self.current_tirra_level)
	print(int(self.current_tirra_level))
	var int_c = int(self.current_tirra_level)
	var next_level = int_c + 1

	return "res://tirra/" + self.colour + "_tirra_" + str(next_level) + ".tscn"


func update_position_on_tirra(player):
	if current_tirra_level <= 0:
		self.update_rider_position_on_tirra_baby(player)
	elif current_tirra_level == 1:
		self.update_rider_position_on_tirra_teen(player)
	else:
		self.update_rider_position_on_tirra_teen(player)


func update_rider_position_on_tirra_baby(player):
	var current_animation_direction = player.current_animation_direction
	var sprite = player.get_node("AnimatedSprite")

	if current_animation_direction == "up":
		sprite.position = Vector2(0, -20)
	elif current_animation_direction == "down":
		sprite.position = Vector2(0, -20)
	elif current_animation_direction == "left":
		sprite.position = Vector2(13, -20)
	elif current_animation_direction == "right":
		sprite.position = Vector2(-13, -20)


func update_rider_position_on_tirra_teen(player):
	var current_animation_direction = player.current_animation_direction
	var sprite = player.get_node("AnimatedSprite")

	if current_animation_direction == "up":
		sprite.position = Vector2(0, -25)
	elif current_animation_direction == "down":
		sprite.position = Vector2(0, -25)
	elif current_animation_direction == "left":
		sprite.position = Vector2(13, -25)
	elif current_animation_direction == "right":
		sprite.position = Vector2(-13, -25)

