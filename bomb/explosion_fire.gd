extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var bomb
var from_player
var player_owner


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func done():
	queue_free()


func _on_AnimatedSprite_animation_finished():
	# $AnimatedSprite.visible = false
	done()
	pass


func _on_Fire_body_entered(body: Node):
	if body.has_method("explode"):
		body.explode()
