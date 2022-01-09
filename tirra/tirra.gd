extends Area2D
# extends "res://items/item.gd"
export(String, "pickup_egg") var pickup_sound

var picked = false
var correct_sound

var current_animation = "idle"

## Nodes
onready var world = get_node("/root/World")
var tirra_owned = false

var grid_position setget grid_position_set, grid_position_get


func grid_position_set(value):
	grid_position = value


func grid_position_get():
	return world.get_grid_position(self.position)


func _ready():
	# $AnimatedSprite.play(item_type)

	var sound_path = "res://sounds/items/" + pickup_sound + ".ogg"
	correct_sound = load(sound_path)


func kick_bomb(player):
	var direction_table = world.direction_table
	var player_grid_pos = player.grid_position
	var forward_vec = direction_table[player.current_animation_direction]
	var forward_grid_position = player_grid_pos + forward_vec
	var bombs = get_tree().get_nodes_in_group("bombs")
	var distance = 3
	for bomb in bombs:
		if bomb.grid_position == forward_grid_position:
			var target = player_grid_pos + (forward_vec * distance)
			bomb.launch(target)


func action(player):
	var animation = "action_" + player.current_animation_direction
	# update_animation(animation)
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play(animation)
	kick_bomb(player)


func update_animation(animation_name):
	if current_animation == animation_name:
		return

	current_animation = animation_name
	# if !$AnimatedSprite.is_playing():
	$AnimatedSprite.play(animation_name)


func award_player(player):
	player.got_egg(grid_position)


# func _ond_Tirasdra_body_entered(body: Node):
# 	print("_on_Tirra_body_entered")
# 	if body.get_class() == "Player":
# 		if picked:
# 			return

# 		picked = true

# 		play_sound()
# 		award_player(body)
# 		$AnimationPlayer.play("picked_up")


func _on_Timer_timeout():
	# $AnimationPlayer.play("spin")
	pass


func play_sound():
	if !$AudioStreamPlayer2D.is_playing():
		$AudioStreamPlayer2D.stream = correct_sound
		$AudioStreamPlayer2D.play()


func explode():
	$AnimationPlayer.play("exploded")


func get_class():
	return "Tirra"


func _on_Tirra_body_entered(body: Node):
	if body.get_class() == "Player":
		if picked:
			return

		picked = true

		play_sound()
		award_player(body)
		# $AnimationPlayer.play("picked_up")
