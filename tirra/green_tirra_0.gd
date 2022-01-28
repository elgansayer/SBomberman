extends "res://tirra/green_tirra.gd"

func reset_rider_speed():
	rider.extra_speed = 100

func force_rider_motion():
	rider.frozen_animation = true
	.force_rider_motion()


func release_rider_motion():
	rider.frozen_animation = false
	rider.forced_motion = Vector2.ZERO


func hit_wall():
	rider.frozen_movement = true
	rider.frozen_animation = true

	var animation = "hit_wall_" + rider.current_animation_direction
	$AnimatedSprite.connect("animation_finished", self, "_on_animation_finished")
	$AnimationPlayer.play(animation)


func _on_animation_finished():
	rider.frozen_movement = false
	$AnimatedSprite.disconnect("animation_finished", self, "_on_animation_finished")
	release_rider_motion()
	reset_rider_speed()
