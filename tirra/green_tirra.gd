extends "res://tirra/blue_tirra.gd"

enum states { STATE_IDLE, STATE_DEAD, STATE_ACTION, STATE_MOVING, STATE_NONE }
var state = states.STATE_NONE

var started_action_position = Vector2.ZERO


func action(player):
	if state == states.STATE_ACTION:
		return

	state = states.STATE_ACTION
	started_action_position = player.position

	# Freeze the player while the tirra is performing an action
	# player.frozen_movement = true
	# player.frozen_animation = true
	# player.forced_motion = world.direction_table[player.current_animation_direction]
	player.forced_move = true
	player.connect("on_collision", self, "_on_Player_collision")

	var animation = "action_" + player.current_animation_direction
	$AnimationPlayer.play(animation)


func _on_Player_collision(_collision):
	rider.forced_move = false
	rider.disconnect("on_collision", self, "_on_Player_collision")
