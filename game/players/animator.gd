extends Node2D

## Nodes
# @onready var actor = self.get_parent()
# @onready var animatedSprite = actor.get_node("AnimatedSprite")

# The actor is the parent node
# var actor
# The mover is the node that supplies the movement
var mover

# The animated sprite is the animated sprite that is animating
var animatedSprite

# @onready var mover = actor.get_node("Mover")
@onready var world = get_node("/root/World")

# Allow the animator to process
var _enabled:bool
@export var enabled:bool:
	get:
		return enabled_get()
	set(value):
		enabled_set(value)

# Set the animator enabled and stop if disabled
func enabled_set(value):
	_enabled = value
	if !value && animatedSprite:
		animatedSprite.stop()


# Is the animator enabled
func enabled_get():
	return _enabled


# The direction description we are facing
var facing_direction = "down"
# How we are moving. Walking or standing
var animation_activity
# Max number of animations seconds
var time_between_anims_default = 250
# Max number of animations seconds
var time_between_anims = time_between_anims_default
# Max number of animations
var last_action_time = 0


func _ready():
	# We dont need physics for this node
	self.set_physics_process(false)


# Set up the animator node
func construct(mover_node, animatedSprite_node):
	mover = mover_node
	animatedSprite = animatedSprite_node


func process():
	if !enabled:
		return

	# var new_direction = facing_direction != anim_data["direction"]

	# if new_direction:
	# 	time_between_anims = 0
	# else:
	# 	time_between_anims = time_between_anims_default

	# var time_between = OS.get_ticks_msec() - last_action_time
	# if time_between < time_between_anims:
	# 	return
	# Animate the sprite

	update_animation()

	# actor.facing_direction = facing_direction


func update_animation():
	# Gets the motion of the actor
	var motion = mover.motion.normalized()

	# Update the animation
	var anim_data = get_animation_dictionary(motion)
	set_animation(anim_data)

	facing_direction = anim_data["direction"]


func set_animation(anim_data):
	var actor_animation = anim_data["animation"]
	var is_new_anim = actor_animation != animatedSprite.animation

	if !is_new_anim:
		return

	# This is a new animation
	#last_action_time = OS.get_ticks_msec()
	animatedSprite.play(actor_animation)


func get_animation_dictionary(motion):
	# Get the description of our motion
	var animation_direction = world.vec_direction_table[motion]

	if animation_direction == "":
		animation_direction = facing_direction

	# Are we walking? or standing still like sheep or cows
	animation_activity = get_animation_activity(motion)

	var anim_prefix = ""  # get_animation_prefix()
	var animation_override = ""

	# elif is_trapped():
	# 	animation_override = "trapped"
	# 	animation_direction = "down"
	# 	anim_prefix = ""

	var final_animation = animation_activity
	if animation_override != "":
		final_animation = animation_override

	var splitter = ""
	if animation_direction != "":
		splitter = "_"

	var new_animation = anim_prefix + final_animation + splitter + animation_direction

	return {
		"animation": new_animation,
		"direction": animation_direction,
		"motion": animation_activity,
	}


func get_animation_activity(motion):
	if motion != Vector2(0, 0):
		return "walk"
	else:
		return "standing"
