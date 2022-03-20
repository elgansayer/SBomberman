extends Node2D
const SPEED_DEFAULT = 10000.0

# Allow the animator to process
@export(bool) var enabled = true setget enabled_set, enabled_get

# The actor is the node that is moving
var actor

var animator_node

# What is the mover direction
var facing_direction setget facing_direction_set, facing_direction_get

# Force continuous movement in any direction
var forced_move = false

# The motion
var motion = Vector2.ZERO

# The direction which was pressed as inpout
var pressed_direction

# Force movement in a direction
var forced_direction setget forced_direction_set, forced_direction_get

var speed = 10000.0

## Nodes
@onready var world = get_node("/root/World")

var puppet_pos = Vector2()
var puppet_motion = Vector2()


puppet func _update_state(p_pos, p_motion):
	puppet_pos = p_pos
	puppet_motion = p_motion


# What is the mover direction
func facing_direction_set(value):
	facing_direction = value


# What is the mover direction
func facing_direction_get():
	if !animator_node:
		print(actor)

	return animator_node.facing_direction


# Force movement in a direction
func enabled_set(value):
	enabled = value


# Force movement in a direction
func enabled_get():
	return enabled


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
func construct(mover, animation_node):
	actor = mover
	animator_node = animation_node


func _ready():
	# We dont need physics for this node
	self.set_physics_process(false)


func process(delta):
	if !enabled:
		return

	if !is_instance_valid(world):
		return	

	if is_network_master():
		motion = update_input()

	var move_motion = (motion.normalized() * speed) * delta
	actor.move_and_slide(move_motion)

	if is_network_master():
		rpc_unreliable("_update_state", actor.position, motion)
	else:
		actor.position = puppet_pos
		motion = puppet_motion

	# if not is_network_master():
	# 	puppet_pos = position  # To avoid jitter

	# if is_network_master():
	# 	rset("puppet_motion", motion)
	# 	rset("puppet_pos", position)
	# else:
	# 	position = puppet_pos
	# 	motion = puppet_motion


func update_input():
	var input_motion = Vector2()

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
