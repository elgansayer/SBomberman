extends "res://players/mover.gd"


func update_input():
	var input_motion = Vector2()

	# Force an actor to move in a specific direction
	if forced_direction:
		return forced_direction

	# force an actor to move in a direction
	# if forced_move:
	# 	if input_motion.x != 0 || input_motion.y != 0:
	# 		return input_motion
	# 	else:
	# 		return world.direction_table[self.facing_direction]

	return input_motion


func process(delta):
	if !enabled:
		return

	if is_network_master():
		motion = update_input()

	var move_motion = (motion.normalized() * speed) * delta
	actor.move_and_slide(move_motion)

	# if is_network_master():
	# 	rset("puppet_motion", motion)
	# 	rset("puppet_pos", position)
	# else:
	# 	position = puppet_pos
	# 	motion = puppet_motion
