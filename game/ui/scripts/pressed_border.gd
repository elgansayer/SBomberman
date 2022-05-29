@tool
extends Node2D

@export var size_offset: Vector2 = Vector2(4, 3)

func _ready():
	var parent = self.get_parent()
	
	_on_parent_resized()
	parent.connect("resized", _on_parent_resized)	
	parent.connect("toggled", _on_parent_toggled)

func _on_parent_resized():
	var parent = self.get_parent()

	var size = parent.get_size()
	var newSize = size + size_offset
	$NinePatchBorder.set_size(newSize)

func _on_parent_toggled(pressed):
	print("_on_parent_toggled", pressed)
	if pressed:
		_on_focus_entered()
	else:
		_on_focus_exited()
		
func _on_focus_entered():
	self.visible = true

	var parent = self.get_parent()	
	if parent.is_class("Button") && parent.disabled == true:
		self.visible = false

func _on_focus_exited():
	self.visible = false
