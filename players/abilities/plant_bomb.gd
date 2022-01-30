extends "res://players/abilities/ability.gd"

# Track how many bombs planted
var bomb_index = 0
# The player's current bombs
var active_bombs = []
# Max number of bombs
var max_bombs = 1


func _ready():
	input_action = "set_bomb"


func process_action():
	# Can't plant bomb if we just tried,
	# Can't plant bomb if we are carrying a bomb
	# Cant plant a bomb if we exceeded bombs left
	# If we are frozen, we can't plant a bomb
	# if (
	# 	prev_bombing
	# 	|| frozen_movement
	# 	|| frozen_animation
	# 	|| in_power_glove
	# 	|| active_bombs.size() >= stat_bombs
	# ):
	# 	return

	# Check if we are enabled and if we have bombs left
	if !enabled || active_bombs.size() >= max_bombs:
		return

	# The same as snap to grid
	var grid_pos = world.get_grid_position(actor.position)
	var bomb_pos = world.get_center_position_from_grid(grid_pos)

	# Cant plant a bomb where there already is one
	var bombs = get_tree().get_nodes_in_group("bombs")
	for bomb in bombs:
		if bomb.grid_position == grid_pos || bomb.position == bomb_pos:
			return

	rpc("setup_bomb", bomb_pos)


# Use sync because it will be called everywhere
remotesync func setup_bomb(bomb_pos):
	var bomb_name = String(get_name()) + str(bomb_index)
	bomb_index += 1

	# Ensure unique name for the bomb
	var bomb = preload("res://bomb/bomb.tscn").instance()
	bomb.set_name(bomb_name)

	bomb.stat_power = actor.stat_power
	bomb.position = bomb_pos
	bomb.from_player = actor
	bomb.player_owner = actor

	# Track the bomb in the active bombs list
	track_bomb(bomb)

	# No need to set network master to bomb, will be owned by server by default
	get_node("/root/World/Bombs").add_child(bomb)


func track_bomb(bomb):
	# Increment the bombs active and planted
	bomb.connect("on_explode", self, "_on_Bomb_exploded")
	# Track bombs we have planted until they explode
	active_bombs.append(bomb)


func _on_Bomb_exploded(bomb):
	active_bombs.erase(bomb)