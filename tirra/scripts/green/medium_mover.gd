extends "res://players/mover.gd"

var skidding = false
signal stopped_skidding


func process(delta):
	if !enabled:
		return

	if is_network_master():
		motion = update_input()

	var move_motion = (motion.normalized() * speed) * delta
	actor.move_and_slide(move_motion)


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

	#pressed_direction = world.vec_direction_table[input_motion]

	# Force an actor to move in a specific direction
	if forced_direction:
		var rev_forced_direction = forced_direction * Vector2(-1, -1)
		if input_motion == rev_forced_direction && !skidding:
			skidding = true
			$SkidTimer.start()

		return forced_direction

	# force an actor to move in a direction
	if forced_move:
		if input_motion.x != 0 || input_motion.y != 0:
			return input_motion
		else:
			return world.direction_table[self.facing_direction]

	return input_motion


func _on_SkidTimer_timeout():
	if self.speed > 0:
		self.speed -= 2000
	elif self.speed <= 0:
		self.speed = 0
		skidding = false
		forced_direction = null
		$SkidTimer.stop()
		emit_signal("stopped_skidding")
