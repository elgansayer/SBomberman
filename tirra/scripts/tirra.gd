extends Area2D

# Has an actor landed this as an item?
var landed_on_tirra = false
# The riding player
var rider
# The riders animation player
var riderAnimationPlayer
# The riders animation sprite
var riderAnimationSprite

var correct_sound
enum TIRRA_LEVEL { small, middle, big }
const tirra_levels = ["small", "medium", "big"]
export(String, "blue", "pink", "yellow", "green") var colour
export(TIRRA_LEVEL) var tirra_level = TIRRA_LEVEL.small

## Nodes
onready var world = get_node("/root/World")

var grid_position setget grid_position_set, grid_position_get

# The last animation played
# var $Animator.facing_direction = "down"
var action = false


# When the player first spawns
func _ready():
	add_to_group(world.group_tirras)

	# $Animator.construct($Mover, $AnimatedSprite)
	# print_tree()


func query_input():
	if is_network_master():
		action = Input.is_action_pressed("action")


func grid_position_set(value):
	grid_position = value


func grid_position_get():
	return world.get_grid_position(self.position)


# Physcs update function
func _physics_process(delta):
	if !rider || !landed_on_tirra:
		return

	$Mover.process(delta)
	$Animator.process()


func _process(_delta):
	if !rider || !landed_on_tirra:
		return

	query_input()

	# update_animation()
	# $Animator.process()

	if action:
		perform_action()

	update_position_on_tirra()


func perform_action():
	var animation = "action_" + $Animator.facing_direction
	$AnimatedSprite.play(animation)


func award_player(player):
	if rider:
		return

	print("award player")
	rider = player
	var tirra_grid_position = self.grid_position

	# if tirra_grid_position != player.grid_position:
	# 	return

	var jump_gravity = 1000
	var custom_height = 1.15
	player.launch(tirra_grid_position, custom_height, jump_gravity)
	# $Animator.facing_direction = $Mover.facing_direction


func play_sound():
	if !$AudioStreamPlayer2D.is_playing():
		$AudioStreamPlayer2D.stream = correct_sound
		$AudioStreamPlayer2D.play()


func explode():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("explode")


func get_class():
	return "Tirra"


func _on_Tirra_body_entered(body: Node):
	# We landed on the tirra after a jhump
	if rider && landed_on_tirra:
		return

	if body.get_class() == "Player":
		# if we are not the rider
		if rider && rider != body:
			return
		# We landed on the tirra after a jhump
		elif rider && !landed_on_tirra:
			landed_on_tirra = true
			call_deferred("attach_rider_to_tirra", rider)
			return
		# We are the same rider
		elif rider:
			return
		# Player has a tirra but the tirra is lonely
		elif !rider && body.tirra:
			landed_on_tirra = true
			call_deferred("upgrade_tirra", body)
			return
		# play_sound()
		call_deferred("award_player", body)


func upgrade_tirra(player):
	if player.tirra && player.tirra.tirra_level >= player.tirra.TIRRA_LEVEL.big:
		return

	# Delete the old tirra and make a new one!
	var old_tirra = player.tirra

	var next_level = old_tirra.tirra_level + 1
	var tirra_path = (
		"res://tirra/tirra_"
		+ str(old_tirra.colour)
		+ "_"
		+ old_tirra.tirra_levels[next_level]
		+ ".tscn"
	)

	var tirra = load(tirra_path).instance()
	tirra.position = old_tirra.position
	tirra.add_to_group(world.group_tirras)

	# Remove the old tirra
	old_tirra.queue_free()
	self.queue_free()

	# Set the new tirra
	tirra.attach_rider_to_tirra(player)


func attach_rider_to_tirra(player):
	# In-case we came from an egg
	if rider:
		# Ensure we landed
		rider.landed()

	# Can't be picked up anymore
	$CollisionShape2D.disabled = true
	landed_on_tirra = true

	riderAnimationPlayer = player.get_node("AnimationPlayer")
	riderAnimationSprite = player.get_node("AnimatedSprite")

	# in-case we came from an upgrade
	rider = player

	if $Mover:
		$Mover.construct(rider)

	if $Animator:
		$Animator.setup($Mover, $AnimatedSprite, $AnimationPlayer, riderAnimationSprite)

	# The rider is now on the tirra
	rider.tirra = self

	self.position = Vector2(0, 0)
	self.z_as_relative = false

	# If we are in the world already.
	var new_parent = self.get_parent()
	if new_parent:
		new_parent.remove_child(self)

	# No need to set network master to bomb, will be owned by server by default
	rider.add_child(self)

	# Set that we are now riding
	riderAnimationPlayer.play("ride_" + rider.facing_direction)

	# Turn on tirra moving/animations
	$Animator.enabled = true
	$Mover.enabled = true


func update_position_on_tirra():
	if tirra_level <= 0:
		self.update_rider_position_on_tirra_small()
	elif tirra_level == 1:
		self.update_rider_position_on_tirra_middle()
	else:
		self.update_rider_position_on_tirra_big()


func update_rider_position_on_tirra_small():
	var direction = $Animator.facing_direction

	if direction == "up":
		riderAnimationSprite.position = Vector2(0, -20)
	elif direction == "down":
		riderAnimationSprite.position = Vector2(0, -20)
	elif direction == "left":
		riderAnimationSprite.position = Vector2(13, -20)
	elif direction == "right":
		riderAnimationSprite.position = Vector2(-13, -20)


func update_rider_position_on_tirra_middle():
	var direction = $Animator.facing_direction

	if direction == "up":
		riderAnimationSprite.position = Vector2(0, -25)
	elif direction == "down":
		riderAnimationSprite.position = Vector2(0, -25)
	elif direction == "left":
		riderAnimationSprite.position = Vector2(13, -25)
	elif direction == "right":
		riderAnimationSprite.position = Vector2(-13, -25)


func update_rider_position_on_tirra_big():
	var direction = $Animator.facing_direction

	if direction == "up":
		riderAnimationSprite.position = Vector2(0, -45)
	elif direction == "down":
		riderAnimationSprite.position = Vector2(0, -45)
	elif direction == "left":
		riderAnimationSprite.position = Vector2(13, -45)
	elif direction == "right":
		riderAnimationSprite.position = Vector2(-13, -45)

# func update_animation():
# 	# Update the animation
# 	var anim_motion = $Mover.motion
# 	var anim_data = get_animation_dictionary(anim_motion)
# 	var tirra_animation = anim_data["animation"]
# 	var rider_animation = anim_data["rider"]

# 	set_animation(tirra_animation, rider_animation)

# func get_animation_dictionary(anim_motion):
# 	var animation_direction = world.vec_direction_table[anim_motion]
# 	var animation_activity = get_animation_activity(anim_motion)

# 	if animation_direction == "":
# 		animation_direction = $Animator.facing_direction

# 	$Animator.facing_direction = animation_direction
# 	var new_animation = animation_activity + "_" + animation_direction
# 	var rider_animation = "ride" + "_" + animation_direction

# 	return {
# 		"animation": new_animation,
# 		"direction": animation_direction,
# 		"motion": animation_activity,
# 		"rider": rider_animation,
# 	}

# func get_animation_activity(anim_motion):
# 	if anim_motion != Vector2(0, 0):
# 		return "walk"
# 	else:
# 		return "standing"

# func set_animation(tirra_animation, rider_animation):
# 	if tirra_animation != $AnimatedSprite.animation:
# 		$AnimatedSprite.play(tirra_animation)

# 	# We can only update the rider animation if we are riding (landed_on_tirra)
# 	if rider_animation != riderAnimationSprite.animation:
# 		riderAnimationSprite.play(rider_animation)
