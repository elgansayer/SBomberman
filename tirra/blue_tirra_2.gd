extends "res://tirra/blue_tirra.gd"

var z_index_table = {
	"up": 1,
	"down": 0,
	"left": 1,
	"right": 1,
}

enum states { STATE_IDLE, STATE_DEAD, STATE_ACTION, STATE_MOVING, STATE_NONE }
var state = states.STATE_NONE


func _ready():
	current_tirra_level = 2


func action(player):
	if state == states.STATE_ACTION:
		return

	state = states.STATE_ACTION

	# Freeze the player while the tirra is performing an action
	player.frozen_movement = true
	player.frozen_animation = true

	var animation = "action_" + player.current_animation_direction
	$AnimationPlayer.play(animation)


func _on_AnimatedSprite_animation_finished():
	self.update_position_on_tirra(rider)

	# Freeze the player while the tirra is performing an action
	rider.frozen_movement = false
	rider.frozen_animation = false

	state = states.STATE_NONE


func update_rider_face_down():
	update_rider("down")


func update_rider_face_left():
	update_rider("left")


func update_rider_face_right():
	update_rider("right")


func update_rider_face_up():
	update_rider("up")


func update_rider(direction):
	if !rider:
		return

	var sprite = rider.get_node("AnimatedSprite")
	update_rider_position_on_tirra_big(sprite, direction)
	play_rider_animation(direction)
	rider.z_index = z_index_table[direction]


func play_rider_animation(new_direction):
	var sprite = rider.get_node("AnimatedSprite")
	var animation_override = "ride_" + new_direction
	sprite.play(animation_override)
	rider.current_animation = animation_override  #"ride_" + rider.current_animation_direction
