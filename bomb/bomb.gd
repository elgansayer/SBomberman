extends "res://scripts/throwable.gd"

### Variables ###

# Gravity of the bomb for bouncing and throwing
# export(int) var GRAVITY = 3000

## Nodes
# onready var world = get_node("/root/World")

# Position of bomb in the world on the network
# puppet var puppet_pos = Vector2()
# Motion of bomb in the world on the network
# puppet var puppet_motion = Vector2()

var from_player
var player_owner
var exploded = false
var stat_power
# Is the bomb paused?
var paused setget paused_set, paused_get

# The bombs cant colide with players that are on the same spot when they are planted
var collision_exceptions = []

## Nodes
# onready var world = get_node("/root/World")


func paused_set(value):
	var anim = "paused"
	if value:
		anim = "paused"
	else:
		anim = "idle"

	$AnimationPlayer.play(anim)
	$AnimationPlayer.seek(0)
	paused = value


func paused_get():
	return paused  # Getter must return a value.


signal on_explode(bomb)


# Use sync because it will be called everywhere
remotesync func setup_explosion(bomb):
	print("setup_explosion")
	var name = String(get_name()) + "_explosion"

	var explosion = preload("res://explosion/explosion.tscn").instance()
	explosion.set_name(name)  # Ensure unique name for the explosion

	explosion.bomb = bomb
	explosion.max_explosion_length = bomb.stat_power
	explosion.bomb_body = self
	explosion.position = world.get_center_position_from_grid(bomb.grid_position)
	explosion.from_player = bomb.from_player
	explosion.player_owner = bomb.player_owner

	emit_signal("on_explode", bomb)

	# No need to set network master to explosion, will be owned by server by default
	get_node("/root/World/Explosions").add_child(explosion)


func _ready():
	add_to_group("bombs")
	# puppet_pos = position
	# grid_position = world.get_grid_position(position)
	var player = world.get_group_node_at(self.grid_position, world.group_players)
	if player:
		collision_exceptions.append(player)
		player.add_collision_exception_with(self)


func landed():
	.landed()
	check_landed_on_item()
	paused_set(false)


func check_landed_on_item():
	var collision_mask = world.layers.LAYER_ITEMS
	var space_state = get_world_2d().direct_space_state

	var result = space_state.intersect_point(
		self.global_position, 1, [self], collision_mask, true, true
	)

	if !result.empty():
		var collider = result[0].collider
		if collider && collider.has_method("dizzy"):
			collider.dizzy()


func launch(grid_target, height_scale = 1.1, gravity_scale = GRAVITY_DEFAULT):
	self.paused = true

	print("bomb launching ", grid_target)
	.launch(grid_target, height_scale, gravity_scale)


func throw(grid_target):
	self.launch(grid_target)

	# Plays a go sound
	var throw_sound = preload("res://sounds/items/go.ogg")
	$AudioStreamPlayer2D.stream = throw_sound
	$AudioStreamPlayer2D.play()


func set_network_position(new_position):
	position = new_position
	rset("puppet_pos", new_position)


func _physics_process(_delta):
	#print("bomb throwable ", flying)

	for player in collision_exceptions:
		if player.grid_position != self.grid_position && !$Area2D.overlaps_body(player):
			player.remove_collision_exception_with(self)
			collision_exceptions.erase(player)


func explode():
	if exploded:
		return

	print("Bomb exploded")
	exploded = true
	$AnimationPlayer.play("explode")

	if not is_network_master():
		# Explode only on master.
		return

	rpc("setup_explosion", self)


func get_class():
	return "Bomb"
