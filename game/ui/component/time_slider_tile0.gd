extends GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	$HSlider.connect("value_changed", _on_drag_ended)
	_on_drag_ended($HSlider.value)
	
func _on_drag_ended(value: float):
	var intValue= int(value)
	
	var str_value = str(intValue)  + ":00"
	if value < 10.0:
		str_value = "0" + str(intValue)  + ":00"
		
	$lblValue.text = str_value
