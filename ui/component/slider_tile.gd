extends GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	$HSlider.connect("value_changed", _on_drag_ended)
	_on_drag_ended($HSlider.value)
	
func _on_drag_ended(value: float):
	var intValue= int(value)
	$lblValue.text = str(intValue)
