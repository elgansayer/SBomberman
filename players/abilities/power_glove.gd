extends "res://players/abilities/ability.gd"

# Nodes
onready var plantBombAbility = abilities.get_node("PlantBomb")
onready var animationPlayer = actor.get_node("AnimationPlayer")
# onready var animator = actor.get_node("Animator")

# We are performing the ability
var in_power_glove = false
# The bomb we are carrying
var bomb
# Direction we are facing
var current_direction = "down"


func _ready():
	input_action = "action"


func process_action():
	# If we are already in the glove, we throw it
	if in_power_glove || bomb:
		pglove_throw()
		return

	bomb = get_bomb()
	if bomb == null:
		return

	in_power_glove = true

	# Turn off our ability to plant bombs
	plantBombAbility.enabled = false

	# # frozen_movement = true
	# # frozen_animation = true

	# Stop the bomb from epxloding, change its animation
	bomb.paused = true

	current_direction = actor.facing_direction
	var animation = "pglove_pickup_" + current_direction
	animationPlayer.play(animation)

	# # Move the bomb per frame
	# $AnimatedSprite.connect("frame_changed", self, "_on_PGlove_frame_changed")
	# $AnimatedSprite.connect("animation_finished", self, "_on_PGlove_animation_finished")
	# $AnimatedSprite.play(animation)

	var new_parent = bomb.get_parent()
	new_parent.remove_child(bomb)
	self.add_child(bomb)
	bomb.set_network_position(Vector2(0, 16))

	# _on_PGlove_frame_changed()


func get_bomb():
	var active_bombs = plantBombAbility.active_bombs
	for i in active_bombs.size():
		var grid_bomb = active_bombs[-i - 1]
		if grid_bomb.grid_position == world.get_grid_position(actor.position):
			return grid_bomb
	return null


func pglove_throw():
	var bomb_global_pos = bomb.global_position

	self.remove_child(bomb)
	get_node("/root/World/Bombs").add_child(bomb)

	bomb.set_network_position(bomb_global_pos)
	bomb.position = bomb_global_pos

	var direction_table = world.direction_table

	# How far the bomb is thrown
	var distance = 3
	var direction_table_vec = direction_table[current_direction] * distance
	var target_grid_position = (
		Vector2(actor.grid_position.x, actor.grid_position.y)
		+ direction_table_vec
	)

	bomb.throw(target_grid_position)

	# var animation = "pglove_pickup_" + current_direction
	# $AnimatedSprite.play(animation, true)
	# $AnimatedSprite.speed_scale = 2.0

	var animation = "pglove_throw_" + current_direction
	animationPlayer.play(animation)

	bomb = null
	in_power_glove = false

	# frozen_movement = false
	# frozen_animation = false


func _on_PGlove_animation_finished():
	pass
	# $AnimatedSprite.disconnect("frame_changed", self, "_on_PGlove_frame_changed")
	# $AnimatedSprite.disconnect("animation_finished", self, "_on_PGlove_animation_finished")

	# frozen_movement = false
	# frozen_animation = false


func frame_changed(frame):
	var bomb_position_table = {
		"up":
		{
			0:
			{
				"pos": Vector2(0, 0),
				"scale": Vector2(0.8, 0.8),
			},
			1:
			{
				"pos": Vector2(0, -8),
				"scale": Vector2(1.0, 1.0),
			},
			2:
			{
				"pos": Vector2(0, -20),
				"scale": Vector2(2.0, 2.0),
			}
		},
		"down":
		{
			0:
			{
				"pos": Vector2(0, 16),
				"scale": Vector2(0.8, 0.8),
			},
			1:
			{
				"pos": Vector2(0, -8),
				"scale": Vector2(1.0, 1.0),
			},
			2:
			{
				"pos": Vector2(0, -20),
				"scale": Vector2(2.0, 2.0),
			}
		},
		"left":
		{
			0:
			{
				"pos": Vector2(-10, 8),
				"scale": Vector2(0.8, 0.8),
			},
			1:
			{
				"pos": Vector2(-16, 0),
				"scale": Vector2(1.0, 1.0),
			},
			2:
			{
				"pos": Vector2(0, -24),
				"scale": Vector2(2.0, 2.0),
			}
		},
		"right":
		{
			0:
			{
				"pos": Vector2(10, 8),
				"scale": Vector2(0.8, 0.8),
			},
			1:
			{
				"pos": Vector2(16, 0),
				"scale": Vector2(1.0, 1.0),
			},
			2:
			{
				"pos": Vector2(0, -24),
				"scale": Vector2(2.0, 2.0),
			}
		}
	}

	var bomb_dict = bomb_position_table[current_direction][frame]
	var bomb_position = bomb_dict["pos"]
	bomb.z_as_relative = false

	if is_network_master():
		bomb.set_network_position(bomb_position)
	else:
		bomb.position = bomb_position
