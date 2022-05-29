extends Control

@export var value: int = 1
@export var min: int = 1
@export var max: int = 10
 
func _on_btn_left_pressed():
	if value > min:
		value-=1
		
	$Panel/Label.text = str(value)
	
func _on_btn_right_pressed():
	if value < max:
		value+=1

	$Panel/Label.text = str(value)
