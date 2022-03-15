extends Node2D

@export var size_offset: Vector2 = Vector2(4, 3)
@export var sizable: NodePath
@export var show_indicators: bool = true
@export var indicators: Array[NodePath] = []

var ninePatchBorder: NinePatchRect

func _ready():
	var size = get_parent().get_size()
	ninePatchBorder = get_node(sizable)
	var newSize = size + size_offset
	ninePatchBorder.set_size(newSize)
			
	for indicatorPath in indicators:
		var indicator = get_node(indicatorPath)
		indicator.visible = show_indicators
			
			
	var indicator2 = get_node(indicators[0])
	var indicator1 = get_node(indicators[1])
		
	var newPos = newSize / 2
	indicator1.position = Vector2(newPos.x, 0)
	indicator2.position = Vector2(newPos.x, newSize.y)
	
func _on_timer_timeout():
	ninePatchBorder.visible = !ninePatchBorder.visible
