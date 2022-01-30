extends Node2D

## Nodes
onready var actor = self.get_parent()
onready var animatedSprite = actor.get_node("AnimatedSprite")
onready var world = get_node("/root/World")

export var flashColour = Color(0, 0, 0)


func _on_FlashTimer_timeout():
	if animatedSprite.self_modulate == flashColour:
		reset_colour()
	else:
		flash_colour()


func flash_colour():
	animatedSprite.self_modulate = flashColour


func _on_VirusTimer_timeout():
	reset()


func reset():
	reset_colour()
	$FlashTimer.stop()


func reset_colour():
	animatedSprite.self_modulate = Color(1, 1, 1)
