extends Node2D

# Sprites created?
var explosion_sprites = []
# How far does this explosion go?
var max_explosion_length = 8
var current_explosion_length = 1
var _timer = null
var bomb = null
var bomb_body = null
const time = 0.02

var from_player
var player_owner

const animation_table = {
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
	spawn_explosions()
	_timer = Timer.new()
	add_child(_timer)

	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(time)
	_timer.set_one_shot(false)  # Make sure it loops
	_timer.start()


func spawn_explosions():
	for dict in explosion_positions:
		var direction_max_length = dict["max_length"]
		if current_explosion_length >= direction_max_length:
			continue

		var vector = dict["vec"]
		var animation = dict["animation"]
		var flip_v = dict["flip_v"]
		var flip_h = dict["flip_h"]
		var name = dict["name"]

		var distance = 32 * current_explosion_length
		var new_x = distance * vector[0]
		var new_y = distance * vector[1]

		var new_position = Vector2(new_x, new_y)
		var new_global_position = Vector2(
			self.global_position.x + new_x, self.global_position.y + new_y
		)
		# var last_global_position = Vector2(new_global_position.x - 16, new_global_position.y - 16)
		var space_state = get_world_2d().direct_space_state

		# use global coordinates, not local to node
		var LayerTilemap = 1
		var LayerRocks = 1 << 1
		# var LayerFire = 1 << 2
		# var LayerBombs = 1 << 3
		# var LayerItems = 1 << 4
		# var LayerPlayers = 1 << 5
		# | LayerItems | LayerPlayers  | LayerBombs
		var ExplosionMask = LayerTilemap | LayerRocks
		var collision_mask = ExplosionMask

		var result = space_state.intersect_ray(
			self.global_position, new_global_position, [bomb, bomb_body], collision_mask, true, true
		)

		if !result.empty():
			var collider = result["collider"]
			# var classname = collider.get_class()

			dict["max_length"] = current_explosion_length

			if collider is TileMap:
				continue

			# if collider is Bomb:
			# 	continue

			print(collider.get_class() + " ", result)

			# if classname == "Rock" || classname == "Bomb":
			# 	# print("set max_length to", current_explosion_length)
			# 	dict["max_length"] = current_explosion_length

			# The fire itself needs to explode it, when it hits it
			# if collider.has_method("explode"):
			# 	collider.explode()

			# print(result, collider.get_class())
			# print(collider, collider.has_method("explode"))

		var sprite = get_new_explosion(new_position)
		sprite.animation = animation
		sprite.flip_v = flip_v
		sprite.flip_h = flip_h
		sprite.set_name(name)
		explosion_sprites.append(sprite)


func get_new_explosion(position):
	var explosion = preload("res://explosion/explosion_fire.tscn").instance()
	explosion.position = position
	var explosion_sprite = explosion.get_node("AnimatedSprite")
	self.add_child(explosion)

	explosion.bomb = self
	explosion.from_player = self.from_player
	explosion.player_owner = self.player_owner

	return explosion_sprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func update_existing_explosion_sprites():
	for sprite in explosion_sprites:
		var new_animation = animation_table[sprite.animation]
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

	update_existing_explosion_sprites()
	spawn_explosions()
	current_explosion_length += 1


func done():
	queue_free()


func get_class():
	return "Explosion"


func is_bit_enabled(mask, index):
	return mask & (1 << index) != 0


func enable_bit(mask, index):
	return mask | (1 << index)


func disable_bit(mask, index):
	return mask & ~(1 << index)
