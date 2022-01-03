extends KinematicBody2D

const MOTION_SPEED = 90.0

# Position of bomb in the world on the network
puppet var puppet_pos = Vector2()
# Motion of bomb in the world on the network
puppet var puppet_motion = Vector2()

const GRAVITY = 3000

onready var screen_size = get_viewport_rect().size

# var in_area = []
var from_player
var player_owner
var exploded = false
var stat_power
# Is the bomb being thrown
var flying = false
# Is the bomb paused?
var paused setget paused_set, paused_get

var target_grid_position = Vector2.ZERO
var target_position = Vector2.ZERO
var velocity = Vector2.ZERO
var launch_direction = Vector2.ZERO
var str_direction = ""
# Position of the bomb in the world tilemap
var grid_position = Vector2()
# The bombs cant colide with players that are on the same spot when they are planted
var collision_exceptions = []


func paused_set(value):
	var anim = "paused"
	# var anim = value ? "paused" : "idle"
	if value:
		anim = "paused"
	else:
		anim = "idle"

	$AnimationPlayer.play(anim)
	$AnimationPlayer.seek(0)
	paused = value


func paused_get():
	return paused  # Getter must return a value.


signal exploded(bomb)


# Use sync because it will be called everywhere
remotesync func setup_explosion(bomb):
	var name = String(get_name()) + "_explosion"

	var grid_size = 32
	var half_grid = grid_size / 2
	var grid_pos = bomb.grid_position
	var explosion_pos = Vector2(
		grid_pos.x * grid_size + half_grid, grid_pos.y * grid_size + half_grid
	)

	var explosion = preload("res://explosion/explosion.tscn").instance()
	explosion.set_name(name)  # Ensure unique name for the explosion

	explosion.bomb = bomb
	explosion.max_explosion_length = bomb.stat_power
	explosion.bomb_body = self
	explosion.position = explosion_pos
	explosion.from_player = bomb.from_player
	explosion.player_owner = bomb.player_owner

	emit_signal("exploded", bomb)

	# # # print("power ", bomb.stat_power)
	# # # print("max_explosion_length ", explosion.max_explosion_length)

	# # # print("Plating explosion at " + str(grid_pos))
	# No need to set network master to explosion, will be owned by server by default
	# self.add_child(explosion)
	get_node("/root/World/Explosions").add_child(explosion)


func _ready():
	add_to_group("bombs")
	puppet_pos = position
	update_grid_position(position)

	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.grid_position == self.grid_position:
			collision_exceptions.append(player)
			player.add_collision_exception_with(self)


func bounce():
	# get_grid_position(position)

	# var direction_table = {
	# 	"up": Vector2(0, -1), "down": Vector2(0, 1), "left": Vector2(-1, 0), "right": Vector2(1, 0)
	# }

	# var abs_x = abs(launch_direction.x)
	# var abs_y = abs(launch_direction.y)
	# var direction = max(abs_x, abs_y)

	# if direction == abs_x:
	# 	str_direction = "right"
	# 	if launch_direction.x < 0:
	# 		str_direction = "left"
	# else:
	# 	str_direction = "up"
	# 	if launch_direction.y > 0:
	# 		str_direction = "down"

	# How far the bomb is thrown
	# var distance = 1
	# var direction_table_vec = direction_table[str_direction] * distance
	# target_grid_position = Vector2(grid_position.x, grid_position.y) + direction_table_vec

	# target_grid_position = Vector2(self.grid_position.x + 1, self.grid_position.y)
	# target_grid_position += Vector2(1, 0)

	target_grid_position += launch_direction
	var target_x = (target_grid_position.x * 32) + 16
	var target_y = (target_grid_position.y * 32) + 16
	target_position = Vector2(target_x, target_y)

	# # print(direction, " ", str_direction, " ", launch_direction)
	# # print("target_grid_position ", target_grid_position)
	# # print("grid_position ", grid_position)
	# Plays a bounce sound
	var bounce_sound = preload("res://sounds/bounce.ogg")
	$AudioStreamPlayer2D.stream = bounce_sound
	$AudioStreamPlayer2D.play()
	launch(target_grid_position)

	# launch(Vector2(position.x + 32, position.y))


func landed():
	paused_set(false)


func throw(grid_target):
	launch(grid_target)

	# Plays a go sound
	var throw_sound = preload("res://sounds/items/go.ogg")
	$AudioStreamPlayer2D.stream = throw_sound
	$AudioStreamPlayer2D.play()


func set_network_position(new_position):
	position = new_position
	rset("puppet_pos", new_position)


func calculate_arc_velocity(source_position, dest_position, arc_height, gravity):
	var arc_velocity = Vector2()
	var displacement = dest_position - source_position

	if displacement.y > arc_height:
		var time_up = sqrt(-2 * arc_height / float(gravity))
		var time_down = sqrt(2 * (displacement.y - arc_height) / float(gravity))
		# # print("time %s" % (time_up + time_down))

		arc_velocity.y = -sqrt(-2 * gravity * arc_height)
		arc_velocity.x = displacement.x / float(time_up + time_down)

	return arc_velocity


func launch(grid_target):
	# THe position on the grid we want to reach
	target_grid_position = grid_target

	# THe coords we want to reach
	var target_x = (target_grid_position.x * 32) + 16
	var target_y = (target_grid_position.y * 32) + 16
	target_position = Vector2(target_x, target_y)

	print("target_grid_position %s" % target_grid_position)
	print("target_position %s" % target_position)
	print("position %s" % position)
	print("global_position %s" % global_position)
	print("grid_position %s" % grid_position)

	# Setup animations
	flying = true
	paused_set(true)
	paused = true

	launch_direction = (Vector2(int(target_position.x), int(target_position.y)) - Vector2(int(global_position.x), int(global_position.y))).normalized()

	print("launch_direction %s" % launch_direction)

	var direction_table = {
		"up": Vector2(0, -1), "down": Vector2(0, 1), "left": Vector2(-1, 0), "right": Vector2(1, 0)
	}

	var abs_x = abs(launch_direction.x)
	var abs_y = abs(launch_direction.y)
	var direction = max(abs_x, abs_y)

	if direction == abs_x:
		str_direction = "right"
		if launch_direction.x < 0:
			str_direction = "left"
	else:
		str_direction = "up"
		if launch_direction.y > 0:
			str_direction = "down"

	# How far the bomb is thrown
	# var distance = 1
	# var direction_table_vec = direction_table[str_direction] * distance
	launch_direction = direction_table[str_direction]

	# calculate arc_height based on distance
	var distance = abs(target_position.x - position.x)
	var max_height = (distance / screen_size.x) * screen_size.y * 0.4
	# - max_height * 0.5
	var arc_height = target_position.y - global_position.y * 1.1

	print("max_height %s " % max_height)
	print("arc_height %s " % arc_height)
	arc_height = min(arc_height, -max_height)
	print("height %s " % arc_height)

	var launch_velocity = calculate_arc_velocity(
		global_position, target_position, arc_height, GRAVITY
	)

	velocity = launch_velocity
	print("velocity %s" % velocity)


func _physics_process(_delta):
	if flying:
		velocity.y += GRAVITY * _delta
		var collision = move_and_collide(velocity * _delta)

		if position.x < 0:
			position.x = screen_size.x
			target_position.x = screen_size.x - 16
			target_grid_position = get_grid_position_for(target_position)
		elif position.x > screen_size.x:
			position.x = 0
			target_position.x = 16
			target_grid_position = get_grid_position_for(target_position)

		if position.y < 0:
			position.y = screen_size.y
			target_position.y = screen_size.y - 16
			target_grid_position = get_grid_position_for(target_position)
		elif position.y > screen_size.y:
			target_position.y = 16
			target_grid_position = get_grid_position_for(target_position)
			position.y = 0

		if velocity.x < 0:  # left
			position.x = clamp(position.x, target_position.x, position.x)

		if velocity.x > 0:  # right
			position.x = clamp(position.x, 0, target_position.x)

		# if velocity.y < 0:  # up
		# 	position.y = clamp(position.y, 0, target_position.y)

		if velocity.y > 0:  # down
			position.y = clamp(position.y, 0, target_position.y)

		update_grid_position(position)

		if collision && collision.collider || (position == target_position):
			flying = false

			# Use global coordinates, not local to node
			var LayerTilemap = 1
			var LayerRocks = 1 << 1
			# var LayerFire = 1 << 2
			var LayerBombs = 1 << 3
			# var LayerItems = 1 << 4
			var LayerPlayers = 1 << 5
			# | LayerItems | LayerPlayers  | LayerBombs
			var BounceMask = LayerTilemap | LayerRocks | LayerBombs | LayerPlayers
			var collision_mask = BounceMask
			# var last_global_position = Vector2(new_global_position.x - 16, new_global_position.y - 16)
			var space_state = get_world_2d().direct_space_state

			var result = space_state.intersect_point(
				self.global_position, 1, [self], collision_mask, true, true
			)

			if !result.empty():
				var collider = result[0].collider
				if collider && collider.has_method("dizzy"):
					collider.dizzy()
									
				bounce()
			else:
				landed()

	for player in collision_exceptions:
		if player.grid_position != self.grid_position && !$Area2D.overlaps_body(player):
			player.remove_collision_exception_with(self)
			collision_exceptions.erase(player)


func get_grid_position_for(position):
	var grid_size = 32
	var grid_x = floor(position.x / grid_size)
	var grid_y = floor(position.y / grid_size)
	var new_grid_position = Vector2(grid_x, grid_y)
	return new_grid_position


func update_grid_position(position):
	grid_position = get_grid_position_for(position)
	return grid_position


func explode():
	# # # print("explode bomb ", is_network_master())
	if exploded:
		return

	exploded = true
	$AnimationPlayer.play("explode")

	if not is_network_master():
		# Explode only on master.
		return

	rpc("setup_explosion", self)


# func done():
# 	queue_free()

# # Use a signal so we can be done with the animation instead of guessing
# func _on_AnimatedSprite_animation_finished():
# 	# # # print(self)
# 	var sprite = $AnimatedSprite
# 	var animation = sprite.animation
# 	# # # print("Finished animation ", animation)
# 	if animation == "explode":
# 		sprite.visible = false


func get_class():
	return "Bomb"
