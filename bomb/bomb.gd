extends KinematicBody2D

const MOTION_SPEED = 90.0

# Position of bomb in the world on the network
puppet var puppet_pos = Vector2()
# Motion of bomb in the world on the network
puppet var puppet_motion = Vector2()

# var in_area = []
var from_player
var player_owner
var exploded = false
var stat_power
# Is the bomb being thrown
var throwing = false
# Is the bomb paused?
var paused setget paused_set, paused_get


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


# Position of the bomb in the world tilemap
var grid_position = Vector2()
# The bombs cant colide with players that are on the same spot when they are planted
var collision_exceptions = []

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


func throw():
	throwing = true


func set_network_position(new_position):
	position = new_position
	rset("puppet_pos", new_position)


var velocity = Vector2()

const GRAVITY = 600

func _physics_process(_delta):
	# if is_network_master():
	# 	rset("puppet_pos", position)
	# else:
	# 	position = puppet_pos
	velocity.y += _delta * GRAVITY
	velocity.y = -5

	# if throwing:
	move_and_collide(velocity)

	get_grid_position(position)

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
