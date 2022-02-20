extends "res://tirra/scripts/tirra.gd"

enum states { STATE_IDLE, STATE_DEAD, STATE_ACTION, STATE_MOVING, STATE_NONE }
var state = states.STATE_NONE


func perform_action():
	if state == states.STATE_ACTION:
		return

	state = states.STATE_ACTION
	$Mover.enabled = false
	$Animator.enabled = false
	kick_bomb()


func kick_bomb():
	var direction_table = world.direction_table
	var player_grid_pos = rider.grid_position
	var forward_vec = direction_table[$Animator.facing_direction]
	var forward_grid_position = player_grid_pos + forward_vec
	var bombs = get_tree().get_nodes_in_group(world.group_bombs)

	var distance = 3 + tirra_level
	var target = player_grid_pos + (forward_vec * distance)
	for bomb in bombs:
		if bomb.grid_position == forward_grid_position:
			var animation = "action_" + $Animator.facing_direction
			$AnimatedSprite.connect("animation_finished", self, "_on_animation_finished")
			$AnimatedSprite.play(animation)
			$AnimationPlayer.play(animation)
			bomb.launch(target)
			return

	state = states.STATE_IDLE
	$Mover.enabled = true
	$Animator.enabled = true


func _on_animation_finished():
	#print("_on_animation_finished")
	state = states.STATE_IDLE
	$Mover.enabled = true
	$Animator.enabled = true
	# $AnimatedSprite.disconnect("animation_finished", self, "_on_animation_finished")


func get_class():
	return "BlueTirra"
