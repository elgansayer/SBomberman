extends Area2D

var picked = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Node2D_body_entered(body: Node):
	if body.get_class() == "Player":
		if picked:
			return

		picked = true
		$AnimationPlayer.play("picked_up")

	pass  # Replace with function body.


func explode():
	$AnimationPlayer.play("exploded")

func get_class():
	return "Item"