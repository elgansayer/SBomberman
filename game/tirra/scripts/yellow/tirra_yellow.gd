extends "res://game/tirra/scripts/tirra.gd"

enum states { STATE_IDLE, STATE_DEAD, STATE_ACTION, STATE_MOVING, STATE_NONE }
var state = states.STATE_NONE


func perform_action():
	if state == states.STATE_ACTION:
		return

	state = states.STATE_ACTION
	$Mover.enabled = false
	$Animator.enabled = false
	scream()


func scream():
	var animation = "action_" + $Animator.facing_direction
	$AnimationPlayer.play(animation)


func on_scream_animation_finished():
	state = states.STATE_IDLE
	$Mover.enabled = true
	$Animator.enabled = true


func get_class():
	return "YellowTirra"
