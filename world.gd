extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var font


func _ready():
	font = DynamicFont.new()
	font.font_data = load("res://montserrat.otf")
	font.size = 10
	# font.modulate = Color(1, 1, 1, 1)
	# font.outline_color = Color(1, 0, 0, 1)
	# font.color = Color(1, 1, 1, 1)
	# font.weight = FontWeight.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


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

