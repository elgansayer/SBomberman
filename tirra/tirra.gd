extends Area2D
# extends "res://items/item.gd"
# export(String, "pickup_egg") var pickup_sound
# enum states { STATE_IDLE, STATE_DEAD, STATE_ACTION, STATE_MOVING, STATE_NONE }
# var state = states.STATE_NONE

var picked = false
var correct_sound
var current_animation = "idle"
export(String, "blue", "pink") var colour
export(int, "small", "middle", "big") var current_tirra_level
# The riding player
var rider

## Nodes
onready var world = get_node("/root/World")
var tirra_owned = false

var grid_position setget grid_position_set, grid_position_get


func grid_position_set(value):
	grid_position = value


func grid_position_get():
	return world.get_grid_position(self.position)


func _ready():
	# Set up the tirra as a small
	$AnimatedSprite.play("standing_down")

	# var sound_path = "res://sounds/items/" + pickup_sound + ".ogg"
	# correct_sound = load(sound_path)


# func upgrade_tirra():
# 	if current_tirra_level >= 3:
# 		return

# 	current_tirra_level = current_tirra_level + 1


func action(player):
	# state = states.STATE_ACTION

	var animation = "action_" + player.current_animation_direction
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play(animation)


func update_animation(animation_name):
	if animation_name == $AnimatedSprite.animation:
		return

	$AnimatedSprite.play(animation_name)


func award_player(player):
	var tirra_grid_position = self.grid_position

	var got_egg = player.got_egg(tirra_grid_position)
	if !got_egg:
		# $AnimationPlayer.play("picked_up")
		queue_free()



func play_sound():
	if !$AudioStreamPlayer2D.is_playing():
		$AudioStreamPlayer2D.stream = correct_sound
		$AudioStreamPlayer2D.play()


func explode():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("explode")
	# state = states.STATE_DEAD


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
	var int_c = int(self.current_tirra_level)
	var next_level = int_c + 1
	return "res://tirra/" + self.colour + "_tirra_" + str(next_level) + ".tscn"


func update_position_on_tirra(player):
	var player_animation_direction = player.current_animation_direction
	var sprite = player.get_node("AnimatedSprite")

	# print("current_animation_direction ", player_animation_direction)

	if current_tirra_level <= 0:
		self.update_rider_position_on_tirra_small(sprite, player_animation_direction)
	elif current_tirra_level == 1:
		self.update_rider_position_on_tirra_middle(sprite, player_animation_direction)
	else:
		self.update_rider_position_on_tirra_big(sprite, player_animation_direction)


func update_rider_position_on_tirra_small(sprite, player_animation_direction):
	if player_animation_direction == "up":
		sprite.position = Vector2(0, -20)
	elif player_animation_direction == "down":
		sprite.position = Vector2(0, -20)
	elif player_animation_direction == "left":
		sprite.position = Vector2(13, -20)
	elif player_animation_direction == "right":
		sprite.position = Vector2(-13, -20)


func update_rider_position_on_tirra_middle(sprite, player_animation_direction):
	if player_animation_direction == "up":
		sprite.position = Vector2(0, -25)
	elif player_animation_direction == "down":
		sprite.position = Vector2(0, -25)
	elif player_animation_direction == "left":
		sprite.position = Vector2(13, -25)
	elif player_animation_direction == "right":
		sprite.position = Vector2(-13, -25)


func update_rider_position_on_tirra_big(sprite, player_animation_direction):
	if player_animation_direction == "up":
		sprite.position = Vector2(0, -45)
	elif player_animation_direction == "down":
		sprite.position = Vector2(0, -45)
	elif player_animation_direction == "left":
		sprite.position = Vector2(13, -45)
	elif player_animation_direction == "right":
		sprite.position = Vector2(-13, -45)
