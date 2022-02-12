extends "res://tirra/scripts/tirra_green.gd"


func perform_action():
	if state == states.STATE_ACTION:
		return

	state = states.STATE_ACTION

	force_rider_motion()
	force_rider_speed()

	var animation = "action_" + $Animator.facing_direction
	$AnimationPlayer.play(animation)

	$Animator.action = true


func update_motion_blur():
	var animation = "action_" + $Animator.facing_direction
	var sprite_frame = $AnimatedSprite.frames
	var texture = sprite_frame.get_frame(animation, 0)
	$MotionBlurParticles.texture = texture


func reset_rider_motion():
	$Mover.forced_move = false


func force_rider_motion():
	$Mover.forced_move = true


func force_rider_speed():
	$Mover.speed += 20000


func hit_wall():
	state = states.STATE_IDLE

	reset_rider_motion()
	reset_rider_speed()

	# Stop the action animations
	$AnimationPlayer.stop()

	# Stop playing the action animation
	$Animator.action = false

	var animation = "hit_wall"
	$AnimationPlayer.play(animation)
