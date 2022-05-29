extends "res://game/players/animator.gd"

# The player animated sprite is the animated sprite that is animating for the player
var playerAnimatedSprite

# The animated player is the animated player that is animating
var animationPlayer

# Set up the animator node
func setup(mover_node, tirraSprite_node, tirraPlayer_node, playerSprite_node):
	super.construct(mover_node, tirraSprite_node)
	playerAnimatedSprite = playerSprite_node
	animationPlayer = tirraPlayer_node


func set_animation(anim_data):
	var tirra_animation = anim_data["animation"]
	var rider_animation = "ride" + "_" + anim_data["direction"]

	# This is a new animation
	#last_action_time = OS.get_ticks_msec()

	if tirra_animation != animatedSprite.animation:
		animatedSprite.play(tirra_animation)

	# We can only update the rider animation if we are riding (landed_on_tirra)
	if rider_animation != playerAnimatedSprite.animation:
		playerAnimatedSprite.play(rider_animation)
