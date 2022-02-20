extends Node2D

onready var actor = self.get_parent()

# Keep track of the flashable behavior
var flashable


# Make the player flash
func _ready():

	# We can't be immortal twice right?
	if actor.immortal:
		return

	#print("Flashable ready")
	flashable = load("res://players/behaviours/white_flashable.tscn").instance()
	actor.add_child(flashable)
	flashable.connect("finshed", self, "finshed")


func finshed():
	flashable.queue_free()
	actor.immortal = false
