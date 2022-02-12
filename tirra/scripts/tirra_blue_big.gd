extends "res://tirra/scripts/tirra_blue.gd"

var z_index_table = {
	"up": 1,
	"down": 0,
	"left": 1,
	"right": 1,
}


func _ready():
	tirra_level = 2


func perform_action():
	if state == states.STATE_ACTION:
		return

	state = states.STATE_ACTION

	# Freeze the player while the tirra is performing an action
	$Mover.enabled = false
	$Animator.enabled = false

	var animation = "action_" + $Animator.facing_direction
	$AnimationPlayer.play(animation)


func _on_AnimatedSprite_animation_finished():
	self.update_position_on_tirra()

	# Freeze the player while the tirra is performing an action
	$Mover.enabled = true
	$Animator.enabled = true

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

	# var sprite = rider.get_node("AnimatedSprite")
	# update_rider_position_on_tirra_big(sprite, direction)
	play_rider_animation(direction)
	rider.z_index = z_index_table[direction]


func play_rider_animation(new_direction):
	# var sprite = rider.get_node("AnimatedSprite")
	var animation_override = "ride_" + new_direction
	riderAnimationSprite.play(animation_override)
	# riderAnimationSprite = animation_override  #"ride_" + rider.facing_direction
