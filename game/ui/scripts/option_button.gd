extends "res://ui/scripts/button.gd"


@export var custom_panel_colour: Color = Color(0,0,0,0)
@export_enum(Blue, Pink, DarkPink, Green, Orange, Yellow, UseCustom) var button_panel_colour = 0


func _ready():

	var desired_colour = colours[button_colour]
	if button_colour == colours.size() -1:
		desired_colour = custom_colour

	var desired_panel_colour = colours[button_panel_colour]
	if button_panel_colour == colours.size() -1:
		desired_panel_colour = custom_panel_colour
		
	var theme = self.get_theme().duplicate()
	
	var new_stylebox_panel_hover: StyleBoxFlat = theme.get_stylebox("hover", "PopupMenu").duplicate()
	var new_stylebox_popupmenu_panel: StyleBoxFlat = theme.get_stylebox("panel", "PopupMenu").duplicate()
	var new_stylebox_normal: StyleBoxFlat = theme.get_stylebox("normal", "OptionButton").duplicate()
	
	new_stylebox_normal.set_bg_color(desired_colour)
	theme.set_stylebox("normal", "OptionButton", new_stylebox_normal)


	var new_stylebox_hover: StyleBoxFlat = new_stylebox_normal.duplicate()
	
	new_stylebox_hover.set_bg_color(desired_colour.lightened(0.6))
	theme.set_stylebox("hover", "OptionButton", new_stylebox_hover)	
	
	new_stylebox_panel_hover.set_bg_color(desired_colour.lightened(0.6))
	theme.set_stylebox("hover", "PopupMenu", new_stylebox_panel_hover)	
	
	var new_stylebox_pressed: StyleBoxFlat = new_stylebox_normal.duplicate()			
	new_stylebox_pressed.set_bg_color(desired_colour.darkened(0.2))
	theme.set_stylebox("pressed", "OptionButton", new_stylebox_pressed)	
	
	var new_stylebox_focus: StyleBoxFlat = new_stylebox_normal.duplicate()		
	new_stylebox_focus.set_bg_color(desired_colour.lightened(0.9))
	theme.set_stylebox("focus", "OptionButton", new_stylebox_focus)	
							
	new_stylebox_popupmenu_panel.set_bg_color(desired_panel_colour)
	theme.set_stylebox("panel", "PopupMenu", new_stylebox_popupmenu_panel)	

	self.set_theme(theme)
		
