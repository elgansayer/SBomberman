extends "res://bomb/scripts/bomb.gd"


func _physics_process(delta):
	._physics_process(delta)

	for i in self.get_slide_count():
		var collision = self.get_slide_collision(i)
		var collider = collision.collider
		if collider:
			bounce_moving_bomb()
