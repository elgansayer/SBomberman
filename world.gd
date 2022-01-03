extends Node2D

export(int) var grid_size = 32
export(int) var half_grid = grid_size / 2

export var direction_table = {
	"up": Vector2(0, -1), "down": Vector2(0, 1), "left": Vector2(-1, 0), "right": Vector2(1, 0)
}

# Called when the node enters the scene tree for the first time.
var font


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
