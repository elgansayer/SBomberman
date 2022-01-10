extends Area2D
# extends "res://items/item.gd"
export(String, "pickup_egg") var pickup_sound

var picked = false
var correct_sound
var current_sprite
var current_animation = "idle"
var current_tirra_level = 1

## Nodes
onready var world = get_node("/root/World")
var tirra_owned = false

var grid_position setget grid_position_set, grid_position_get


func grid_position_set(value):
	grid_position = value


func grid_position_get():
	return world.get_grid_position(self.position)


func _ready():
	## Set up the tirra as a baby
	current_sprite = $AnimatedSprite1

	# current_sprite.play(item_type)

	var sound_path = "res://sounds/items/" + pickup_sound + ".ogg"
	correct_sound = load(sound_path)


func upgrade_tirra():
	if current_tirra_level >= 3:
		return

	current_tirra_level = current_tirra_level + 1

	if current_tirra_level == 1:
		## Set up the tirra as a baby
		current_sprite = $AnimatedSprite1
		$AnimatedSprite1.visible = true
		$AnimatedSprite2.visible = false
		$AnimatedSprite3.visible = false
	elif current_tirra_level == 2:
		## Set up the tirra as a teen
		current_sprite = $AnimatedSprite2
		$AnimatedSprite1.visible = false
		$AnimatedSprite2.visible = true
		$AnimatedSprite3.visible = false
	else:
		## Set up the tirra as a monster
		current_sprite = $AnimatedSprite3
		$AnimatedSprite1.visible = false
		$AnimatedSprite2.visible = false
		$AnimatedSprite3.visible = true


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
	current_sprite.frame = 0
	current_sprite.play(animation)
	kick_bomb(player)


func update_animation(animation_name):
	if current_animation == animation_name:
		return

	current_animation = animation_name
	# if !current_sprite.is_playing():
	current_sprite.play(animation_name)


func award_player(player):
	# if player.riding:
	# 	return
	var tirra_grid_position = self.grid_position
	player.got_egg(tirra_grid_position)


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
