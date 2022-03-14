extends Panel

@export var start_focus: NodePath
@export var tab_container: NodePath
@export var password_edit: NodePath

# Called when the node enters the scene tree for the first time.
func _ready():
	var node = get_node(start_focus)
	node.grab_focus()


func _on_btn_login_pressed():
	var node = get_node(tab_container)
	node.current_tab = 0


func _on_btn_create_account_pressed():
	var node = get_node(tab_container)
	node.current_tab = 1

 
func _on_texture_button_toggled(button_pressed):
	var node = get_node(password_edit)
	node.secret = button_pressed
