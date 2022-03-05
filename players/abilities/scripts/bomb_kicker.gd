extends Node2D

## Nodes
@onready var abilities = self.get_parent()
@onready var actor = abilities.get_parent()
@onready var world = get_node("/root/World")

var enabled = true setget enabled_set


func enabled_set(value):
	enabled = value
	set_physics_process(value)


# Physcs update function
func _physics_process(_delta):
	for i in actor.get_slide_count():
		var collision = actor.get_slide_collision(i)
		var collider = collision.collider

		if collider.has_method("kick_bomb"):
			collider.kick_bomb(actor)
			return
