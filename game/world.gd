@tool
extends Node2D
# Takes 40 soft blocks away
# 20 x 14
@export var update_button: bool:
		set(value):
			return update_pressed()

@export var level_grid_size: Vector2 = Vector2(20, 14)
@export var level_size: Vector2 = Vector2(32, 32)
@export var level_offset: Vector2 = Vector2(16, 32)
@export var grid_size: int = 32
@export var half_grid: int = grid_size / 2
@export var spawn_point_scn: PackedScene
@export var spawn_point_parent: NodePath
@export var soft_block_info_scn: PackedScene
@export var soft_block_info_parent: NodePath

var soft_block_info: Array[float] = [
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
	0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 
	0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 
	0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 
	0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 
	0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 
	0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 
	0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 
	0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 
	0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 
	0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 
	0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 		
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 	
]



func update_pressed():
	if Engine.is_editor_hint():
		spanpoints_set(spawnpoints)
		softblockinfo_set(soft_block_info)
		
@export var spawnpoints: Array[Vector2] = []
#@export var spawnpoints: Array[Vector2]:
#		set(value):
#			spawnpoints = value
#			return spanpoints_set(value)
#		get:
#			return spawnpoints

var spawnpoints_length: int = 0

# Time the map lasts for
@export var time: int = 60 * 3

# Time the map lasts for
@export var time_left: int = time

enum orientation {
	Vertical,
	Horizontal,
}

@export var direction_orientation = {
	"up": orientation.Vertical,
	"down": orientation.Vertical,
	"left": orientation.Horizontal,
	"right": orientation.Horizontal
}

@export var direction_bounce_table = {"up": "down", "down": "up", "left": "right", "right": "left"}

@export var direction_table = {
	"up": Vector2(0, -1), "down": Vector2(0, 1), "left": Vector2(-1, 0), "right": Vector2(1, 0)
}

@export var direction_table_rev = {
	"down": Vector2(0, -1), "up": Vector2(0, 1), "right": Vector2(-1, 0), "left": Vector2(1, 0)
}

@export var vec_direction_table = {
	Vector2(0, 0): "",
	Vector2(0, -1): "up",
	Vector2(0, 1): "down",
	Vector2(-1, 0): "left",
	Vector2(1, 0): "right"
}

@export var vec_direction_table_rev = {
	Vector2(0, 0): "",
	Vector2(0, -1): "down",
	Vector2(0, 1): "up",
	Vector2(-1, 0): "right",
	Vector2(1, 0): "left"
}

enum layers {
	LAYER_TILEMAP = 1,
	LAYER_ROCKS = 1 << 1,
	LAYER_FIRE = 1 << 2,
	LAYER_BOMBS = 1 << 3,
	LAYER_ITEMS = 1 << 4,
	LAYER_PLAYERS = 1 << 5,
}

#func _process(delta):
#	if Engine.is_editor_hint():
#		if spawnpoints_length != spawnpoints.size():
#			spawnpoints_length = spawnpoints.size()
#			spanpoints_set(spawnpoints)
					
		# Code to execute in editor.


func softblockinfo_set(value):
	var parent = get_node(soft_block_info_parent)
	for n in parent.get_children():
		parent.remove_child(n)
		n.queue_free()
	
	var index = 0
	for y in level_grid_size.y:
		for x in level_grid_size.x:		
			var position = get_position_from_grid(Vector2(x,y))
			make_soft_block_info(position, soft_block_info[index])
			index += 1

		
	return value


func spanpoints_set(value):
	var parent = get_node(spawn_point_parent)
	for n in parent.get_children():
		parent.remove_child(n)
		n.queue_free()
		
	for spawnpoint in value:
		var position = get_position_from_grid(spawnpoint)
		make_spawn_point(position)
	return value
	
var blockingMask = layers.LAYER_TILEMAP | layers.LAYER_ROCKS | layers.LAYER_BOMBS

var bounceMask = (
	layers.LAYER_TILEMAP
	| layers.LAYER_ROCKS
	| layers.LAYER_BOMBS
	| layers.LAYER_PLAYERS
)

@export var group_players = "players"
@export var group_bombs = "bombs"
@export var group_tirras = "tirras"

# Called when the node enters the scene tree for the first time.
var font


func make_soft_block_info(position: Vector2, label_text: float):
	var softblockinfo = soft_block_info_scn.instantiate()
	softblockinfo.position = position
	softblockinfo.get_node("Label").text = str(label_text)
	get_node(soft_block_info_parent).add_child(softblockinfo)

func make_spawn_point(position: Vector2):
	var spawnpoint = spawn_point_scn.instantiate()
	spawnpoint.position = position
	get_node(spawn_point_parent).add_child(spawnpoint)

func get_group_node_at(grid_position, group):
	var nodes = get_tree().get_nodes_in_group(group)
	for node in nodes:
		if node.grid_position == grid_position:
			return node


func snap_position_to_grid(position_vec):
	var grid_pos = get_grid_position(position_vec)
	var grid_center_pos = get_center_position_from_grid(grid_pos)
	return grid_center_pos


# Get a position from a grid position and add half grid to become
# center of the grid square.
func get_center_position_from_grid(grid_pos):
	var pos = get_position_from_grid(grid_pos)
	return Vector2(pos.x + half_grid, pos.y + half_grid)


# Get a position from a grid position
func get_position_from_grid(grid_pos):
	return Vector2(grid_pos.x * grid_size, grid_pos.y * grid_size)


# Get a grid position from a position
func get_grid_position(position_vec: Vector2):
	var grid_x = floor(position_vec.x / grid_size)
	var grid_y = floor(position_vec.y / grid_size)
	var new_grid_position = Vector2(grid_x, grid_y)
	return new_grid_position


func _ready():
	pass
	#font = DynamicFont.new()
	#//font.font_data = load("res://montserrat.otf")
	#//font.size = 10


# func _draw():
# 	var x = 0
# 	var y = 0
# 	var rows = 64
# 	var size = 32
# 	var half_size = size / 2
# 	var colour = Color(1.0, 0.0, 1.0, 1.0)
# 	for i in rows:
# 		x = i * size
# 		draw_line(Vector2(x, 0), Vector2(x, 480), Color(255, 0, 0), 1)
# 		for p in rows:
# 			y = i * size
# 			draw_line(Vector2(0, y), Vector2(640, y), Color(255, 0, 0), 1)

# 	for i in 32:
# 		x = i * size
# 		y = 0
# 		var posstr = str(floor(x / size)) + "," + str(floor(y / size))
# 		var sized = font.get_string_size(posstr)
# 		draw_string(
# 			font,
# 			Vector2(x + half_size - (sized.x / 2), y + half_size + (sized.y / 2)),
# 			posstr,
# 			colour
# 		)
# 		for p in 32:
# 			y = p * size
# 			var posstry = str(floor(x / size)) + "," + str(floor(y / size))
# 			var sizedy = font.get_string_size(posstr)
# 			draw_string(
# 				font,
# 				Vector2(x + half_size - (sizedy.x / 2), y + half_size + (sizedy.y / 2)),
# 				posstry,
# 				colour
# 			)


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
