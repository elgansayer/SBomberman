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
var throwing = false
# Is the bomb paused?
var paused setget paused_set, paused_get

var target_grid_position = Vector2.ZERO
var target_position = Vector2.ZERO
var velocity = Vector2.ZERO

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

	# print("power ", bomb.stat_power)
	# print("max_explosion_length ", explosion.max_explosion_length)

	# print("Plating explosion at " + str(grid_pos))
	# No need to set network master to explosion, will be owned by server by default
	# self.add_child(explosion)
	get_node("/root/World/Explosions").add_child(explosion)


func _ready():
	add_to_group("bombs")
	puppet_pos = position
	get_grid_position(position)
	
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.grid_position == self.grid_position:
			collision_exceptions.append(player)
			player.add_collision_exception_with(self)


func bounce():
	target_grid_position = Vector2(self.grid_position.x + 1, self.grid_position.y)
	var target_x = (target_grid_position.x * 32) + 16
	var target_y = (target_grid_position.y * 32) + 16
	target_position = Vector2(target_x, target_y)

	launch(target_position)


func landed():
	paused = false

	var LayerTilemap = 1
	var LayerRocks = 1 << 1
	var LayerFire = 1 << 2
	var LayerBombs = 1 << 3
	var LayerItems = 1 << 4
	var LayerPlayers = 1 << 5
	# # | LayerItems | LayerPlayers  | LayerBombs
	# var BounceMask = LayerTilemap | LayerRocks | LayerBombs | LayerPlayers
	# var collision_mask = BounceMask

	self.collision_mask = LayerBombs
	self.collision_layer = (
		LayerBombs
		| LayerPlayers
		| LayerFire
		| LayerTilemap
		| LayerRocks
		| LayerItems
	)


func throw(grid_target):
	target_grid_position = grid_target
	var target_x = (target_grid_position.x * 32) + 16
	var target_y = (target_grid_position.y * 32) + 16
	target_position = Vector2(target_x, target_y)
	launch(target_position)


func set_network_position(new_position):
	position = new_position
	rset("puppet_pos", new_position)


func calculate_arc_velocity(source_position, dest_position, arc_height, gravity):
	var velocity = Vector2()
	var displacement = dest_position - source_position

	if displacement.y > arc_height:
		var time_up = sqrt(-2 * arc_height / float(gravity))
		var time_down = sqrt(2 * (displacement.y - arc_height) / float(gravity))
		print("time %s" % (time_up + time_down))

		velocity.y = -sqrt(-2 * gravity * arc_height)
		velocity.x = displacement.x / float(time_up + time_down)

	return velocity


func launch(launch_to):
	throwing = true

	# Remove all conflicts
	self.collision_mask = 0
	self.collision_layer = 0

	var direction = (launch_to - position).normalized()
	# make_bounce_bottom(launch_to)

	# calculate arc_height based on distance
	var distance = abs(launch_to.x - position.x)
	var max_height = (distance / screen_size.x) * screen_size.y * 0.4

	var arc_height = launch_to.y - global_position.y - max_height
	arc_height = min(arc_height, -max_height)
	print("height %s" % arc_height)

	velocity = calculate_arc_velocity(global_position, launch_to, arc_height, GRAVITY)


func make_bounce_bottom(launch_to):
	return
	# Create a new Shape
	var shape = RectangleShape2D.new()
	shape.set_extents(Vector2(128, 16))

	# Create a new collisionShape
	var collision_shape = CollisionShape2D.new()
	# Add the shape we created before to this collision shape
	collision_shape.set_shape(shape)

	# Create the StaticBody2D
	var static_body = StaticBody2D.new()
	static_body.collision_mask = (1 << 6)
	static_body.collision_layer = (1 << 6)
	# Add the CollisionShape we've created as child of the StaticBody
	static_body.add_child(collision_shape)
	# Use the drawn line's middle as the position of our StaticBody
	var static_body_position = Vector2(launch_to.x, launch_to.y + 32)
	# Set the StaticBody's position to the middle of the drawn line
	static_body.set_position(static_body_position)
	# Add the StaticBody as a child of the StaticBody
	# add_child(static_body)
	get_node("/root/World/TileMap").add_child(static_body)


func _physics_process(_delta):
	if throwing:
		velocity.y += GRAVITY * _delta
		var collision = move_and_collide(velocity * _delta)
		get_grid_position(position)

		position.x = clamp(position.x, 0, target_position.x)
		position.y = clamp(position.y, 0, target_position.y)

		if collision && collision.collider || (position == target_position):
			throwing = false

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

			var result = space_state.intersect_ray(
				self.global_position, self.global_position, [self], collision_mask, true, true
			)

			print(result)

			if result && result.collider:
				bounce()
			else:
				landed()

	for player in collision_exceptions:
		if player.grid_position != self.grid_position && !$Area2D.overlaps_body(player):
			player.remove_collision_exception_with(self)
			collision_exceptions.erase(player)


func get_grid_position(position):
	var grid_size = 32
	var grid_x = floor(position.x / grid_size)
	var grid_y = floor(position.y / grid_size)
	grid_position = Vector2(grid_x, grid_y)
	return grid_position


func explode():
	# print("explode bomb ", is_network_master())
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
# 	# print(self)
# 	var sprite = $AnimatedSprite
# 	var animation = sprite.animation
# 	# print("Finished animation ", animation)
# 	if animation == "explode":
# 		sprite.visible = false


func get_class():
	return "Bomb"
