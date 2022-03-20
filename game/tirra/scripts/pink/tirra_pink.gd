extends "res://tirra/scripts/tirra.gd"

var jumping = false
var shadow


func attach_rider_to_tirra(player):
	.attach_rider_to_tirra(player)
	rider.connect("landed", self, "_on_rider_landed")


func perform_action():
	if jumping || rider.flying:
		return

	jumping = true
	$Animator.enabled = false
	$Mover.enabled = false

	var shadow_move_dir = world.direction_orientation[$Animator.facing_direction]

	shadow = load("res://scenes/shadow.tscn").instance()
	world.add_child(shadow)
	shadow.position = rider.position
	shadow.constructor(rider, shadow_move_dir)

	.perform_action()
	jump()


func jump():
	# Turn off player animations
	# rider.frozen_movement = true

	var distance = 2 + tirra_level

	# Distance is 0 if we are not "moving"
	if $Animator.facing_direction == "left" && $Mover.motion.x == 0:
		distance = 0
	elif $Animator.facing_direction == "right" && $Mover.motion.x == 0:
		distance = 0
	elif $Animator.facing_direction == "up" && $Mover.motion.y == 0:
		distance = 0
	elif $Animator.facing_direction == "down" && $Mover.motion.y == 0:
		distance = 0

	var jump_gravity = 1000
	var custom_height = 1.15

	var target = rider.position
	if distance != 0:
		var direction_table = world.direction_table
		# var rider_grid_pos = rider.grid_position
		var forward_vec = direction_table[$Animator.facing_direction]

		var grid_stance = world.grid_size * distance
		var new_vec = target + (forward_vec * grid_stance)
		target = new_vec  #rider_grid_pos + (forward_vec * distance)

		# rider.launch(target, custom_height, jump_gravity)
	# else:
	# 	rider.launch_to(target, custom_height, jump_gravity)

	rider.launch_to(target, custom_height, jump_gravity)


func _on_rider_landed():
	$Animator.enabled = true
	$Mover.enabled = true
	jumping = false


func get_sub_class():
	return "PinkTirra"
