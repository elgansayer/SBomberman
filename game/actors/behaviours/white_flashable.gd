extends Node2D

## Nodes
@onready var actor = self.get_parent()
@onready var animatedSprite = actor.get_node("AnimatedSprite")

## Nodes
@onready var animatedSpriteMaterial = animatedSprite.get_material()
@export(float) var intensity = 0.7
@export(Vector3) var colour = Vector3(1, 1, 1)

# Are we flashing
var flash = false

# Signal the flash has finished
signal finished


func _ready():
	animatedSpriteMaterial.set_shader_param("flash_colour", colour)


func _on_FlashTimer_timeout():
	if flash:
		reset_colour()
	else:
		flash_colour()


func flash_colour():
	flash = true
	set_shader_flash(intensity)


func reset_colour():
	flash = false
	set_shader_flash(0)


func set_shader_flash(flash_value):
	animatedSpriteMaterial.set_shader_param("flash_progress", flash_value)


func _on_Timer_timeout():
	reset()
	emit_signal("finished")


func reset():
	reset_colour()
	$FlashTimer.stop()
