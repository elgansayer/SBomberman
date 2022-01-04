extends KinematicBody2D

### Variables ###

# Gravity of the bomb for bouncing and throwing
export(int) var GRAVITY = 3000

## Nodes
onready var world = get_node("/root/World")

# Position of bomb in the world on the network
puppet var puppet_pos = Vector2()
# Motion of bomb in the world on the network
puppet var puppet_motion = Vector2()

# Screen size for bouncing out of the screen
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

# Target grid to move to vector
var target_grid_position = Vector2.ZERO
# Target move to vector
var target_position = Vector2.ZERO
# Vector of actual direction
var velocity = Vector2.ZERO
# Vector of direction
var launch_direction = Vector2.ZERO
# Description of direction
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

	var explosion = preload("res://explosion/explosion.tscn").instance()
	explosion.set_name(name)  # Ensure unique name for the explosion

	explosion.bomb = bomb
	explosion.max_explosion_length = bomb.stat_power
	explosion.bomb_body = self
	explosion.position = world.get_center_position_from_grid(bomb.grid_position)
	explosion.from_player = bomb.from_player
	explosion.player_owner = bomb.player_owner

	emit_signal("exploded", bomb)

	# No need to set network master to explosion, will be owned by server by default
	get_node("/root/World/Explosions").add_child(explosion)


func _ready():
	add_to_group("bombs")
	puppet_pos = position
	grid_position = world.get_grid_position(position)

	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.grid_position == self.grid_position:
			collision_exceptions.append(player)
			player.add_collision_exception_with(self)


func bounce():
	target_grid_position += launch_direction
	target_position = world.get_center_position_from_grid(target_grid_position)

	# Plays a bounce sound
	var bounce_sound = preload("res://sounds/bounce.ogg")
	$AudioStreamPlayer2D.stream = bounce_sound
	$AudioStreamPlayer2D.play()
	launch(target_grid_position)


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
	target_position = world.get_center_position_from_grid(target_grid_position)

	# Setup animations
	flying = true
	paused_set(true)
	paused = true

	launch_direction = (Vector2(int(target_position.x), int(target_position.y)) - Vector2(int(global_position.x), int(global_position.y))).normalized()

	var direction_table = world.direction_table
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
	launch_direction = direction_table[str_direction]

	# calculate arc_height based on distance
	var distance = abs(target_position.x - position.x)
	var max_height = (distance / screen_size.x) * screen_size.y * 0.4
	# - max_height * 0.5
	var arc_height = target_position.y - global_position.y * 1.1
	arc_height = min(arc_height, -max_height)

	var launch_velocity = calculate_arc_velocity(
		global_position, target_position, arc_height, GRAVITY
	)

	velocity = launch_velocity


func _physics_process(_delta):
	if flying:
		velocity.y += GRAVITY * _delta
		var collision = move_and_collide(velocity * _delta)

		if position.x < 0:
			position.x = screen_size.x
			target_position.x = screen_size.x - 16
			target_grid_position = world.get_grid_position(target_position)
		elif position.x > screen_size.x:
			position.x = 0
			target_position.x = 16
			target_grid_position = world.get_grid_position(target_position)

		if position.y < 0:
			position.y = screen_size.y
			target_position.y = screen_size.y - 16
			target_grid_position = world.get_grid_position(target_position)
		elif position.y > screen_size.y:
			target_position.y = 16
			target_grid_position = world.get_grid_position(target_position)
			position.y = 0

		if velocity.x < 0:  # left
			position.x = clamp(position.x, target_position.x, position.x)

		if velocity.x > 0:  # right
			position.x = clamp(position.x, 0, target_position.x)

		# if velocity.y < 0:  # up
		# 	position.y = clamp(position.y, 0, target_position.y)

		if velocity.y > 0:  # down
			position.y = clamp(position.y, 0, target_position.y)

		grid_position = world.get_grid_position(position)

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


func explode():
	if exploded:
		return

	exploded = true
	$AnimationPlayer.play("explode")

	if not is_network_master():
		# Explode only on master.
		return

	rpc("setup_explosion", self)


func get_class():
	return "Bomb"
