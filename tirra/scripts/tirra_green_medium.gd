extends "res://tirra/scripts/tirra_green.gd"

var last_direction
var direction_table = {"up": "down", "down": "up", "left": "right", "right": "left"}


# func update_animation(animation_name):
# 	if animation_name == $AnimatedSprite.animation:
# 		return

# 	if state == states.STATE_IDLE:
# 		$AnimatedSprite.play(animation_name)


func action(player):
	last_direction = rider.facing_direction
	.action(player)


func should_skid():
	return rider.pressed_direction == direction_table[rider.facing_direction]


func skid():
	print("skid")
	# $Animator.enabled = true
	# rider.frozen_movement = true
	state = states.STATE_SKIDDING
	$AnimatedSprite/RightFeetAnimatedSprite.visible = false
	$AnimatedSprite/LeftFeetAnimatedSprite.visible = false

	var animation = "skid_" + rider.facing_direction
	$AnimationPlayer.play(animation)


func check_rider_stopped():
	.check_rider_stopped()

	print(rider.pressed_direction, " ", direction_table[rider.facing_direction])

	if should_skid():
		print("should_skid() ", should_skid())
		skid()


func reset_rider_speed():
	$Mover.extra_speed = 200


func hit_wall():
	.hit_wall()
	$AnimatedSprite.play("standing_" + rider.facing_direction)

	$AnimatedSprite/RightFeetAnimatedSprite.visible = false
	$AnimatedSprite/LeftFeetAnimatedSprite.visible = false

# extends "res://tirra/green_tirra.gd"

# var last_direction

# func action(player):
# 	player.forced_move = true
# 	player.extra_speed = 200
# 	state = states.STATE_ACTION
# 	update_speed_anim()
# 	$Timer.start()

# func update_speed_anim():
# 	last_direction = rider.facing_direction
# 	var animation = "action_" + last_direction
# 	$AnimationPlayer.play(animation)

# func update_animation(animation_name):
# 	if animation_name == $AnimatedSprite.animation:
# 		return

# 	if state == states.STATE_IDLE:
# 		$AnimatedSprite.play(animation_name)
# 	elif state == states.STATE_STOPPED:
# 		$AnimatedSprite.play("standing_" + rider.facing_direction)
# 	elif last_direction != rider.facing_direction:
# 		update_speed_anim()

# func _on_Timer_timeout():
# 	rider.forced_move = false
# 	$Mover.extra_speed = 0
# 	state = states.STATE_IDLE
# 	$AnimatedSprite/RightFeetAnimatedSprite.visible = false
# 	$AnimatedSprite/LeftFeetAnimatedSprite.visible = false

# func same_spot():
# 	if state == states.STATE_STOPPED:
# 		return

# 	print("same_spot")
# 	var collision = rider.get_last_slide_collision()
# 	if collision && collision.collider:
# 		state = states.STATE_STOPPED
# 		$AnimatedSprite/RightFeetAnimatedSprite.visible = false
# 		$AnimatedSprite/LeftFeetAnimatedSprite.visible = false

# func _physics_process(_delta):
# 	if !rider:
# 		return

# 	if state == states.STATE_IDLE:
# 		return

# 	# We are in the same place
# 	if last_position == rider.position || rider.motion.x == 0 && rider.motion.y == 0:
# 		same_spot()
# 	elif state == states.STATE_STOPPED:
# 		update_speed_anim()
# 	else:
# 		state = states.STATE_ACTION

# 	# Set the last position
# 	last_position = rider.position
