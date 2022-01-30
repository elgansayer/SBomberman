extends "res://tirra/tirra.gd"

enum states { STATE_IDLE, STATE_ACTION, STATE_SKIDDING }
var state = states.STATE_IDLE
var last_position = Vector2.ZERO


func perform_action():
	if state == states.STATE_ACTION:
		return

	state = states.STATE_ACTION

	force_rider_motion()
	force_rider_speed()

	$Animator.action = true
	.perform_action()


func reset_rider_speed():
	$Mover.extra_speed = 0


func reset_rider_motion():
	$Mover.forced_direction = false


func force_rider_speed():
	$Mover.extra_speed = 1000


func force_rider_motion():
	$Mover.forced_direction = $Animator.facing_direction


func hit_wall():
	state = states.STATE_IDLE

	reset_rider_motion()
	reset_rider_speed()

	# Stop the action animations
	$AnimationPlayer.stop()

	# Stop playing the action animation
	$Animator.action = false

	# Disable the input
	$Mover.enabled = false
	$Animator.enabled = false

	var animation = "hit_wall_" + $Animator.facing_direction
	$AnimatedSprite.connect("animation_finished", self, "_on_animation_finished")
	$AnimationPlayer.play(animation)


func same_spot():
	var collision = rider.get_last_slide_collision()
	if collision && collision.collider:
		state = states.STATE_IDLE
		hit_wall()


func _physics_process(_delta):
	if !rider:
		return

	if state != states.STATE_ACTION:
		return

	check_rider_stopped()


func check_rider_stopped():
	# We are int he same place
	if last_position == rider.position:
		same_spot()

	# Set the last position
	last_position = rider.position


func _on_animation_finished():
	# Enable the movement
	$Mover.enabled = true
	$Animator.enabled = true

	$AnimatedSprite.disconnect("animation_finished", self, "_on_animation_finished")
	reset_rider_motion()
	reset_rider_speed()
