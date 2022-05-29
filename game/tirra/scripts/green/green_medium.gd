extends "res://game/tirra/scripts/green/tirra_green.gd"


func _ready():
	$Mover.connect("stopped_skidding", self, "_stopped_skidding")


func force_rider_speed():
	$Mover.speed += 5000


func hit_wall():
	state = states.STATE_IDLE

	.reset_rider_motion()
	.reset_rider_speed()

	# Stop the action animations
	$AnimationPlayer.stop()

	# Stop playing the action animation
	$Animator.action = false
	# Ensure we are no longer skidding
	$Mover.skidding = false

	var animation = "hit_wall_" + $Animator.facing_direction
	$AnimationPlayer.play(animation)


func _stopped_skidding():
	hit_wall()
