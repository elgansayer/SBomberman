@tool
extends Node2D

@export var size_offset: Vector2 = Vector2(4, 3)
@export var show_indicators: bool = true
@export var indicators: Array[NodePath] = []

func _ready():
	var parent = self.get_parent()
	if !parent.has_focus():
		self.visible = false
	
	_on_parent_resized()
	parent.connect("resized", _on_parent_resized)	
	parent.connect("focus_entered", _on_focus_entered)
	parent.connect("focus_exited", _on_focus_exited)
	$Timer.start()
	
func _on_parent_resized():
	var parent = self.get_parent()
	
	if !parent.has_focus():
		self.visible = false
		$Timer.stop()
		
	var size = parent.get_size()
	var newSize = size + size_offset
	$NinePatchBorder.set_size(newSize)
			
	for indicatorPath in indicators:
		var indicator = get_node(indicatorPath)
		indicator.visible = show_indicators
		
	var indicator2 = get_node(indicators[0])
	var indicator1 = get_node(indicators[1])
		
	var newPos = newSize / 2
	indicator1.position = Vector2(newPos.x, 0)
	indicator2.position = Vector2(newPos.x, newSize.y)
	
func _on_focus_entered():
	self.visible = true
	$Timer.start()
	
	var parent = self.get_parent()	
	if parent.is_class("Button") && parent.disabled == true:
		self.visible = false
		$Timer.stop()
	
func _on_focus_exited():
	self.visible = false
	$Timer.stop()

func _on_timer_timeout():
	$NinePatchBorder.visible = !$NinePatchBorder.visible
