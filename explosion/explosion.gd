extends Node2D

## Nodes
onready var world = get_node("/root/World")

# Sprites created?
var explosion_sprites = []

var current_explosion_length = 1
var _timer = null
var bomb = null
var bomb_body = null
const time = 0.02

# How far does this explosion go?
var max_explosion_length setget max_explosion_length_set, max_explosion_length_get


func max_explosion_length_set(value):
	for dict in explosion_positions:
		dict["max_length"] = value
		max_explosion_length = value


func max_explosion_length_get():
	return max_explosion_length  # Getter must return a value.


var from_player
var player_owner

const animation_swap_table = {
	"middle": "middle",
	"h_end": "h_middle",
	"v_end": "v_middle",
	"h_middle": "h_middle",
	"v_middle": "v_middle",
}

var explosion_positions = [
	{
		# middle
		"name": "middle",
		"vec": [0, 0],
		"flip_v": false,
		"flip_h": false,
		"animation": "middle",
		"max_length": max_explosion_length,
	},
	{
		# left
		"name": "left",
		"vec": [-1, 0],
		"flip_v": false,
		"flip_h": false,
		"animation": "h_end",
		"max_length": max_explosion_length,
	},
	{
		# right
		"name": "right",
		"vec": [1, 0],
		"flip_v": false,
		"flip_h": true,
		"animation": "h_end",
		"max_length": max_explosion_length,
	},
	{
		# up
		"name": "up",
		"vec": [0, -1],
		"flip_v": false,
		"flip_h": false,
		"animation": "v_end",
		"max_length": max_explosion_length,
	},
	{
		# down
		"name": "down",
		"vec": [0, 1],
		"flip_v": true,
		"flip_h": false,
		"animation": "v_end",
		"max_length": max_explosion_length,
	},
]


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_explosion_fire()
	_timer = Timer.new()
	add_child(_timer)

	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(time)
	_timer.set_one_shot(false)  # Make sure it loops
	_timer.start()


func spawn_fire_sprites():
	var space_state = get_world_2d().direct_space_state
	var distance = world.grid_size * current_explosion_length

	for dict in explosion_positions:
		var direction_max_length = dict["max_length"]
		if current_explosion_length >= direction_max_length:
			continue

		var vector = dict["vec"]
		var animation = dict["animation"]
		var flip_v = dict["flip_v"]
		var flip_h = dict["flip_h"]
		var name = dict["name"]

		var new_x = distance * vector[0]
		var new_y = distance * vector[1]

		var new_position = Vector2(new_x, new_y)
		var new_global_position = Vector2(
			self.global_position.x + new_x, self.global_position.y + new_y
		)

		# use global coordinates, not local to node
		var LayerTilemap = 1
		var LayerRocks = 1 << 1

		var ExplosionMask = LayerTilemap | LayerRocks
		var collision_mask = ExplosionMask

		var result = space_state.intersect_ray(
			self.global_position, new_global_position, [bomb, bomb_body], collision_mask, true, true
		)

		if !result.empty():
			var collider = result["collider"]

			dict["max_length"] = current_explosion_length

			if collider is TileMap:
				continue

			print(collider.get_class() + " ", result)

		var sprite = get_new_fire(new_position)
		sprite.animation = animation
		sprite.flip_v = flip_v
		sprite.flip_h = flip_h
		sprite.set_name(name)
		explosion_sprites.append(sprite)


func get_new_fire(position):
	var fire = preload("res://explosion/explosion_fire.tscn").instance()
	fire.position = position
	var explosion_sprite = fire.get_node("AnimatedSprite")
	self.add_child(fire)

	fire.bomb = self
	fire.from_player = self.from_player
	fire.player_owner = self.player_owner

	return explosion_sprite


func update_existing_fire_sprites():
	for sprite in explosion_sprites:
		var new_animation = animation_swap_table[sprite.animation]
		sprite.animation = new_animation


func play_explosion_sprites():
	for sprite in explosion_sprites:
		sprite.play()


func _on_Timer_timeout():
	if current_explosion_length >= max_explosion_length:
		play_explosion_sprites()
		_timer.stop()
		_timer.disconnect("timeout", self, "_on_Timer_timeout")
		_timer = null
		return

	spawn_explosion_fire()


func spawn_explosion_fire():
	print("Explosion length: ", current_explosion_length)
	update_existing_fire_sprites()
	spawn_fire_sprites()
	current_explosion_length += 1


func get_class():
	return "Explosion"


func is_bit_enabled(mask, index):
	return mask & (1 << index) != 0


func enable_bit(mask, index):
	return mask | (1 << index)


func disable_bit(mask, index):
	return mask & ~(1 << index)
