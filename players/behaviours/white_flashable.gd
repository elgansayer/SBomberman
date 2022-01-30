extends Node2D

## Nodes
onready var actor = self.get_parent()
onready var animatedSprite = actor.get_node("AnimatedSprite")

## Nodes
onready var animatedSpriteMaterial = animatedSprite.get_material()
export(float) var white_intensity = 0.7

# Are we flashing
var flash = false

# Signal the flash has finished
signal finished

func _on_FlashTimer_timeout():
	if flash:
		reset_colour()
	else:
		flash_colour()


func flash_colour():
	flash = true
	set_white(white_intensity)


func reset_colour():
	flash = false
	set_white(0)


func set_white(white_value):
	animatedSpriteMaterial.set_shader_param("white_progress", white_value)


func _on_Timer_timeout():
	reset()
	emit_signal("finished")

func reset():
	reset_colour()
	$FlashTimer.stop()
