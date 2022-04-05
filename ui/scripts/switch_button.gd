extends GridContainer

@export var Buttons: Array[NodePath] = []

# Called when the node enters the scene tree for the first time.
func _ready():

	for buttonPath in Buttons:
		var button = get_node(buttonPath)
		button.connect('pressed', _on_button_pressed, [button])
		
func switch_off_all():
	for buttonPath in Buttons:
		var button = get_node(buttonPath)
		button.button_pressed = false
		
func _on_button_pressed(button):
	switch_off_all()
	button.button_pressed = true
