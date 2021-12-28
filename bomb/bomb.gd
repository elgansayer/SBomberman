extends KinematicBody2D

# Position of bomb in the world on the network
puppet var puppet_pos = Vector2()
# Motion of bomb in the world on the network
puppet var puppet_motion = Vector2()

# var in_area = []
var from_player
var player_owner
var exploded = false

# Position of the bomb in the world tilemap
var grid_position = Vector2()
# The bombs cant colide with players that are on the same spot when they are planted
var collision_exceptions = []


# Use sync because it will be called everywhere
remotesync func setup_explosion(bomb):
	var name = String(get_name()) + "_explosion"

	var grid_size = 32
	var half_grid = grid_size / 2
	var grid_pos = bomb.grid_position
	var explosion_pos = Vector2(
		grid_pos.x * grid_size + half_grid, grid_pos.y * grid_size + half_grid
	)

	var explosion = preload("res://bomb/explosion.tscn").instance()
	explosion.set_name(name)  # Ensure unique name for the explosion

	explosion.bomb = bomb
	explosion.bomb_body = self
	explosion.position = explosion_pos
	explosion.from_player = bomb.from_player
	explosion.player_owner = bomb.player_owner

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


func _physics_process(_delta):
	if is_network_master():
		rset("puppet_pos", position)
	else:
		position = puppet_pos

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


# Called from the animation.
func anim_explode_now():
	explode()


func explode():
	# print("explode ", is_network_master())
	if exploded:
		return
	exploded = true
	$AnimationPlayer.play("explode")

	if not is_network_master():
		# Explode only on master.
		return

	rpc("setup_explosion", self)


func done():
	queue_free()


# Use a signal so we can be done with the animation instead of guessing
func _on_AnimatedSprite_animation_finished():
	# print(self)
	var sprite = $AnimatedSprite
	var animation = sprite.animation
	# print("Finished animation ", animation)
	if animation == "explode":
		done()

func get_class():
	return "Bomb"