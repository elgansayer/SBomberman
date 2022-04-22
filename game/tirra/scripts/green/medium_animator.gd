extends "res://game/tirra/scripts/green/green_animator.gd"

# Are we skidding?
var skidding = false


func set_animation(anim_data):
	var tirra_animation = anim_data["animation"]
	var rider_animation = "ride" + "_" + anim_data["direction"]

	# This is a new animation
	#last_action_time = OS.get_ticks_msec()

	# We are skidding so set the animation to skid
	if mover.skidding:
		tirra_animation = "skid" + "_" + anim_data["direction"]
		animationPlayer.play(tirra_animation)

		# Player plays the other way
		playerAnimatedSprite.play(rider_animation)
		return

	# We can only update the rider animation if we are riding (landed_on_tirra)
	if rider_animation != playerAnimatedSprite.animation:
		playerAnimatedSprite.play(rider_animation)

	if action && tirra_animation != animationPlayer.current_animation:
		tirra_animation = "action" + "_" + anim_data["direction"]
		animationPlayer.play(tirra_animation)
		return

	if tirra_animation != animatedSprite.animation:
		animatedSprite.play(tirra_animation)
