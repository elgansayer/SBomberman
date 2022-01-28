extends "res://tirra/tirra.gd"

enum states { STATE_IDLE, STATE_ACTION, STATE_SKIDDING }
var state = states.STATE_IDLE
var last_position = Vector2.ZERO
var started_action_position = Vector2.ZERO


func action(player):
	if state == states.STATE_ACTION:
		return

	state = states.STATE_ACTION
	started_action_position = player.position

	force_rider_motion()
	force_rider_speed()

	var animation = "action_" + player.current_animation_direction
	$AnimationPlayer.play(animation)

func update_animation(animation_name):
	if animation_name == $AnimatedSprite.animation:
		return

	$AnimatedSprite.play(animation_name)

func reset_rider_speed():
	rider.extra_speed = 0


func force_rider_speed():
	rider.extra_speed = 100


func release_rider_motion():
	rider.forced_motion = Vector2.ZERO


func force_rider_motion():
	rider.forced_motion = world.direction_table[rider.current_animation_direction]


func hit_wall():
	release_rider_motion()
	reset_rider_speed()


func same_spot():
	var collision = rider.get_last_slide_collision()
	if collision && collision.collider:
		state = states.STATE_IDLE
		hit_wall()

	reset_rider_speed()


func _physics_process(_delta):
	if !rider:
		return

	if state != states.STATE_ACTION:
		return

	check_rider_stopped()


func check_rider_stopped():
	# We are int he same place
	if last_position == rider.position || rider.motion.x == 0 && rider.motion.y == 0:
		same_spot()

	# Set the last position
	last_position = rider.position
