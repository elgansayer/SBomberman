extends "res://tirra/green_tirra.gd"


# func reset_rider_speed():
# 	$Mover.extra_speed = 100


# func force_rider_motion():
# 	$Animator.enabled = true
# 	.force_rider_motion()
# 	pass


# func release_rider_motion():
# 	# $Animator.enabled = false
# 	# rider.forced_motion = Vector2.ZERO
# 	pass


# func hit_wall():
# 	# rider.frozen_movement = true
# 	# $Animator.enabled = true

# 	var animation = "hit_wall_" + rider.facing_direction
# 	$AnimatedSprite.connect("animation_finished", self, "_on_animation_finished")
# 	$AnimationPlayer.play(animation)


# func _on_animation_finished():
# 	# rider.frozen_movement = false
# 	$AnimatedSprite.disconnect("animation_finished", self, "_on_animation_finished")
# 	release_rider_motion()
# 	reset_rider_speed()
