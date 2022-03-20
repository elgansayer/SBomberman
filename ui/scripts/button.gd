@tool
extends Button
@export var custom_colour: Color = Color(0,0,0,0)
var colours: Array[Color] = [		
		Color('10d8f8'), # Blue
		Color('f8a0e0'), # Pink 
		Color('f87898'), # Dark Pink 
		Color('68e810'), # Green
		Color('f8b000'), # Orange
		Color('f8e848'), # Yellow
			
		Color(0,0,0,0), # Use custom
	]

enum ButtonColour {Blue, DarkPink, Pink, Green, Orange, Yellow, UseCustom}
@export_enum(Blue, Pink, DarkPink, Green, Orange, Yellow, UseCustom) var button_colour 

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var desired_colour = colours[button_colour]
	if button_colour == colours.size() -1:
		desired_colour = custom_colour
		
	var theme = self.get_theme().duplicate()
	
	var new_stylebox_normal: StyleBoxFlat = theme.get_stylebox("normal", "Button").duplicate()
	new_stylebox_normal.set_bg_color(desired_colour)
	theme.set_stylebox("normal", "Button", new_stylebox_normal)

	var new_stylebox_hover: StyleBoxFlat = new_stylebox_normal.duplicate()		
	new_stylebox_hover.set_bg_color(desired_colour.lightened(0.6))
	theme.set_stylebox("hover", "Button", new_stylebox_hover)	
	
	var new_stylebox_pressed: StyleBoxFlat = new_stylebox_normal.duplicate()		
	new_stylebox_pressed.set_bg_color(desired_colour.darkened(0.2))
	theme.set_stylebox("pressed", "Button", new_stylebox_pressed)	
		
	self.set_theme(theme)
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
