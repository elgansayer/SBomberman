extends Node2D

const MOTION_SPEED = 10000.0

## Nodes
onready var world = get_node("/root/World")
# onready var actor = self.get_parent()

# The actor is the node that is moving
var actor

# Allow the animator to process
export(bool) var enabled = true

# Force continuous movement in any direction
var forced_move = false

# THe motion
var motion = Vector2.ZERO

# The direction which was pressed as inpout
var pressed_direction
var extra_speed = 0

# Force movement in a direction
var forced_direction setget forced_direction_set, forced_direction_get


# Force movement in a direction
func forced_direction_set(direction):
	if direction:
		forced_direction = world.direction_table[direction]
	else:
		forced_direction = null


# Force movement in a direction
func forced_direction_get():
	return forced_direction


# Set up the mover node
func construct(mover):
	actor = mover


func _ready():
	# We dont need physics for this node
	self.set_physics_process(false)


func process(delta):
	if !enabled:
		return

	if is_network_master():
		motion = update_input()

	var speed = MOTION_SPEED + extra_speed
	var move_motion = (motion.normalized() * speed) * delta
	actor.move_and_slide(move_motion)

	# if is_network_master():
	# 	rset("puppet_motion", motion)
	# 	rset("puppet_pos", position)
	# else:
	# 	position = puppet_pos
	# 	motion = puppet_motion


func update_input():
	var input_motion = Vector2()

	if is_network_master():
		if Input.is_action_pressed("move_left"):
			input_motion = Vector2(-1, 0)
		if Input.is_action_pressed("move_right"):
			input_motion = Vector2(1, 0)
		if Input.is_action_pressed("move_up"):
			input_motion = Vector2(0, -1)
		if Input.is_action_pressed("move_down"):
			input_motion = Vector2(0, 1)

	pressed_direction = world.vec_direction_table[input_motion]

	# Force an actor to move in a specific direction
	if forced_direction:
		return forced_direction

	# force an actor to move in a direction
	if forced_move:
		if input_motion.x != 0 || input_motion.y != 0:
			return input_motion
		else:
			return world.direction_table[self.facing_direction]

	return input_motion
