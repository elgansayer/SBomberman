extends Area2D

var bomb
var from_player
var player_owner


func _on_AnimatedSprite_animation_finished():
	queue_free()


func _on_Fire_body_entered(body: Node):
	#print("_on_Fire_body_entered ", body.get_class())
	if body.has_method("explode"):
		body.call_deferred("explode")


func get_class():
	return "Fire"


func _on_Fire_area_entered(area: Area2D):
	#print("_on_Fire_area_entered ", area.get_class())
	if area.has_method("explode"):
		area.call_deferred("explode")
