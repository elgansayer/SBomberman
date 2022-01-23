extends Node2D

export(int) var grid_size = 32
export(int) var half_grid = grid_size / 2

# Time the map lasts for
export(int) var time = 60 * 3

# Time the map lasts for
export(int) var time_left = time

export var direction_table = {
	"up": Vector2(0, -1), "down": Vector2(0, 1), "left": Vector2(-1, 0), "right": Vector2(1, 0)
}

enum layers {
	LAYER_TILEMAP = 1,
	LAYER_ROCKS = 1 << 1,
	LAYER_FIRE = 1 << 2,
	LAYER_BOMBS = 1 << 3,
	LAYER_ITEMS = 1 << 4,
	LAYER_PLAYERS = 1 << 5,
}

var blockingMask = layers.LAYER_TILEMAP | layers.LAYER_ROCKS | layers.LAYER_BOMBS

var bounceMask = (
	layers.LAYER_TILEMAP
	| layers.LAYER_ROCKS
	| layers.LAYER_BOMBS
	| layers.LAYER_PLAYERS
)

export var group_players = "players"
export var group_bombs = "bombs"
export var group_tirras = "tirras"

# Called when the node enters the scene tree for the first time.
var font


func get_group_node_at(grid_position, group):
	var nodes = get_tree().get_nodes_in_group(group)
	for node in nodes:
		if node.grid_position == grid_position:
			return node


func snap_position_to_grid(position_vec):
	var grid_pos = get_center_position_from_grid(position_vec)
	return get_position_from_grid(grid_pos)


# Get a position from a grid position and add half grid to become
# center of the grid square.
func get_center_position_from_grid(grid_pos):
	var pos = get_position_from_grid(grid_pos)
	return Vector2(pos.x + half_grid, pos.y + half_grid)


# Get a position from a grid position
func get_position_from_grid(grid_pos):
	return Vector2(grid_pos.x * grid_size, grid_pos.y * grid_size)


# Get a grid position from a position
func get_grid_position(position_vec):
	var grid_x = floor(position_vec.x / grid_size)
	var grid_y = floor(position_vec.y / grid_size)
	var new_grid_position = Vector2(grid_x, grid_y)
	return new_grid_position


func _ready():
	font = DynamicFont.new()
	font.font_data = load("res://montserrat.otf")
	font.size = 10


func _draw():
	var x = 0
	var y = 0
	var rows = 64
	var size = 32
	var half_size = size / 2
	var colour = Color(1.0, 0.0, 1.0, 1.0)
	for i in rows:
		x = i * size
		draw_line(Vector2(x, 0), Vector2(x, 480), Color(255, 0, 0), 1)
		for p in rows:
			y = i * size
			draw_line(Vector2(0, y), Vector2(640, y), Color(255, 0, 0), 1)

	for i in 32:
		x = i * size
		y = 0
		var posstr = str(floor(x / size)) + "," + str(floor(y / size))
		var sized = font.get_string_size(posstr)
		draw_string(
			font,
			Vector2(x + half_size - (sized.x / 2), y + half_size + (sized.y / 2)),
			posstr,
			colour
		)
		for p in 32:
			y = p * size
			var posstry = str(floor(x / size)) + "," + str(floor(y / size))
			var sizedy = font.get_string_size(posstr)
			draw_string(
				font,
				Vector2(x + half_size - (sizedy.x / 2), y + half_size + (sizedy.y / 2)),
				posstry,
				colour
			)


func _on_ClockTimer_timeout():
	time_left = time_left - 1

	# if time_left <= 0:
	# 	get_node("/root/Game").visible = False
	# 	get_node("/root/Game").enabled = False
	# 	get_node("/root/Game").call("_end_game")

	var minutes = time_left / 60
	var seconds = time_left % 60

	if minutes < 10:
		minutes = "0" + str(minutes)
	if seconds < 10:
		seconds = "0" + str(seconds)

	$InfoBoard.get_node("ClockLabel").set_text(str(minutes) + ":" + str(seconds))
