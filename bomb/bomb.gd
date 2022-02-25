extends "res://scripts/throwable.gd"
signal on_explode(bomb)

export(Resource) var explosion_scene
export(Resource) var throw_sound

# res://explosion/explosion.tscn
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
var paused setget paused_set

# The bombs cant colide with players that are on the same spot when they are planted
var collision_exceptions = []

## Nodes
# onready var world = get_node("/root/World")

# Make the bomb explode when it hits something
var explode_on_impact = false


func paused_set(value):
	var anim = "paused"
	if value:
		anim = "paused"
	else:
		anim = "idle"

	$AnimationPlayer.play(anim)
	$AnimationPlayer.seek(0)
	paused = value


# Use sync because it will be called everywhere
remotesync func setup_explosion(bomb):
	#//#print("setup_explosion")
	var name = String(get_name()) + "_explosion"

	var explosion = explosion_scene.instance()
	explosion.set_name(name)  # Ensure unique name for the explosion

	explosion.bomb = bomb
	explosion.max_explosion_length = bomb.stat_power
	explosion.bomb_body = self
	explosion.position = world.snap_position_to_grid(bomb.position)
	explosion.from_player = bomb.from_player
	explosion.player_owner = bomb.player_owner

	emit_signal("on_explode", bomb)

	# No need to set network master to explosion, will be owned by server by default
	get_node("/root/World/Explosions").add_child(explosion)


func _ready():
	add_to_group("bombs")
	# puppet_pos = position
	# grid_position = world.get_grid_position(position)
	# var player = world.get_group_node_at(self.grid_position, world.group_players)
	# if player:
	# 	collision_exceptions.append(player)
	# 	player.add_collision_exception_with(self)


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

	#//#print("bomb launching ", grid_target)
	.launch(grid_target, height_scale, gravity_scale)


func throw(grid_target):
	self.launch(grid_target)

	# Plays a go sound
	# var ThrowSound = preload(throw_sound)
	# $AudioStreamPlayer2D.stream = ThrowSound
	# $AudioStreamPlayer2D.play()


func set_network_position(new_position):
	position = new_position
	rset("puppet_pos", new_position)


func _physics_process(delta):
	##//#print("bomb throwable ", flying)
	$Mover.process(delta)

	if explode_on_impact:
		for i in self.get_slide_count():
			var collision = self.get_slide_collision(i)
			var collider = collision.collider

			if collider:
				explode()

	# for player in collision_exceptions:
	# 	var distance_sq = (player.position - self.position).length_squared()
	# 	print("distance_sq", distance_sq)
	# 	var distance = abs(distance_sq)
	# 	if distance > 7:
	# 		player.remove_collision_exception_with(self)
	# 		collision_exceptions.erase(player)


# Physcs update function


func explode():
	if exploded:
		return

	exploded = true

	# Turn off physics
	self.set_physics_process(false)

	# Stop any emitting motion blur
	$MotionBlurParticles.emitting = false

	#//#print("Bomb
	$AnimationPlayer.play("explode")

	# Stop the bomb travelling
	$Mover.enabled = false

	if not is_network_master():
		# Explode only on master.
		return

	rpc("setup_explosion", self)


func get_class():
	return "Bomb"


func kick_bomb(player: Node):
	var animator = player.get_node("Animator")

	$Mover.speed += 5000
	$Mover.construct(self, animator)
	$Mover.enabled = true
	$Mover.forced_direction = animator.facing_direction
	# $Mover.forced_move = true


func fire_marble_bomb(player: Node):
	var animator = player.get_node("Animator")

	collision_exceptions.append(player)
	player.add_collision_exception_with(self)

	explode_on_impact = true
	$MotionBlurParticles.emitting = true
	$Mover.speed += 15000
	$Mover.construct(self, animator)
	$Mover.enabled = true
	$Mover.forced_direction = animator.facing_direction
	# $Mover.forced_move = true
	enable_moving_bodies()


func enable_moving_bodies():
	# Disable all the bodies and use the moving one
	$MovingBodyShape.disabled = false
	# Now all the normal bodies
	$CollisionShapeInnerLeft.disabled = true
	$CollisionShapeinnerRight.disabled = true
	$CollisionShapeInnerUp.disabled = true
	$CollisionShapeinnerDown.disabled = true
	$CollisionShapeOuterLeft.disabled = true
	$CollisionShapeOuterRight.disabled = true
	$CollisionShapeOuterUp.disabled = true
	$CollisionShapeOuterDown.disabled = true


# func _on_Area2D_body_entered(body: Node):
# 	if body.get_class() != "Player":
# 		return

# 	for player in collision_exceptions:
# 		if player == body:
# 			return

# 	if body.stat_bomb_kicker:
# 		kick_bomb(body)


func _on_Area2D_area_entered(area: Area2D):
	if area.has_method("bomb_hit"):
		area.bomb_hit()
