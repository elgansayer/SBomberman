extends Node

## Nodes
onready var abilities = self.get_parent()
onready var actor = abilities.get_parent()
onready var world = get_node("/root/World")

# Action to check input for
export var input_action = "action"
# Is the node performing an action?
var action = false
# Is the ability enabled
var enabled = true
# Max number of bombs seconds
var time_between_actions = 100
# Max number of bombs
var last_action_time = 0


func _ready():
	# We dont need physics for this node
	self.set_physics_process(false)


func query_input(event):
	if is_network_master():
		action = event.is_action_pressed(input_action)

func _input(event):
	var time_between = OS.get_ticks_msec() - last_action_time
	if time_between < time_between_actions:
		return
	
	if is_network_master():
		query_input(event)

	if action:
		last_action_time = OS.get_ticks_msec()
		process_action()


func process_action():
	pass
