extends Node2D

## Nodes
onready var abilities = self.get_parent()
onready var actor = abilities.get_parent()
onready var world = get_node("/root/World")
onready var animatedSprite = actor.get_node("AnimatedSprite")
onready var animatedSpriteMaterial = animatedSprite.get_material()
onready var plantBombAbility = abilities.get_node("PlantBomb")

export(float) var flashIntensity = 0.9
export(Vector3) var flashColour = Vector3(1, 1, 0)

# Action to check input for
export var input_action = "set_bomb"
# Is the node performing an action?
var action = false
# Is the ability enabled
var enabled = true
# Max number of bombs seconds
var time_held_for = 0
var seconds_hold_for = 2
var seconds_start_at = 0.3
var in_hold = false
var flashing = true

var start_wait_time = 0.3
var bomb


func _ready():
	# We dont need physics for this node
	self.set_physics_process(false)
	animatedSpriteMaterial.set_shader_param("flash_colour", flashColour)


func query_input():
	if is_network_master():
		action = Input.is_action_pressed(input_action)


func _process(delta):
	# Check if we are enabled and if we have bombs left
	# if !enabled || active_bombs.size() >= max_bombs:
	# 	return

	if is_network_master():
		query_input()

	if action:
		if !in_hold:
			bomb = get_bomb()

		if bomb == null:
			reset_bomb()
			reset()
			return

		# Keep counting
		time_held_for += delta

		if !in_hold && time_held_for >= seconds_start_at:
			flash_colour()
			$FlashTimer.start(start_wait_time)
			in_hold = true
			bomb.visible = false
			bomb.paused = true
			bomb.set_physics_process(false)

	elif in_hold:
		reset_bomb()

		# WE FIRE!!!
		if time_held_for >= seconds_hold_for:
			process_action()

		reset()


# func _input(event):
# 	# var time_between = OS.get_ticks_msec() - last_action_time
# 	# if time_between < time_held_for:
# 	# 	return

# 	if is_network_master():
# 		query_input(event)

# 	if action:
# 		if !holding:
# 			holding = true
# 			last_action_time = OS.get_ticks_sec()

# 		var time_now = OS.get_ticks_sec()
# 		var time_between = time_now - last_action_time
# 		if time_between > 2:
# 			process_action()
# 			last_action_time = OS.get_ticks_sec()


func process_action():
	pass
	# if bomb:
	# bomb.fire_marble_bomb(actor)


func _on_FlashTimer_timeout():
	if flashing:
		reset_colour()
	else:
		flash_colour()

	$FlashTimer.wait_time *= 0.9

	if $FlashTimer.wait_time <= 0.1:
		flash_colour()
		$FlashTimer.stop()


func flash_colour():
	flashing = true
	animatedSpriteMaterial.set_shader_param("flash_progress", flashIntensity)


func reset_bomb():
	if bomb:
		bomb.visible = true
		bomb.position = world.snap_position_to_grid(actor.position)
		bomb.paused = false
		bomb.set_physics_process(true)


func reset():
	reset_colour()
	$FlashTimer.stop()
	time_held_for = 0
	in_hold = false


func reset_colour():
	flashing = false
	animatedSpriteMaterial.set_shader_param("flash_progress", 0)


func get_bomb():
	var active_bombs = plantBombAbility.active_bombs
	for i in active_bombs.size():
		var grid_bomb = active_bombs[-i - 1]
		if grid_bomb.grid_position == actor.grid_position:
			return grid_bomb
	return null
