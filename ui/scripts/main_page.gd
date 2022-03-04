extends Panel

## BtnStartGame
onready var BtnStartGame = get_node("BtnStartGame")
## BtnJoinGame
onready var BtnJoinGame = get_node("BtnJoinGame")
## BtnOptionsGame
onready var BtnOptionsGame = get_node("BtnOptionsGame")

## BtnStartNode
# onready var BtnStartNode = BtnStartGame.get_node("Node2D")
# ## BtnJoinNode
# onready var BtnJoinNode = BtnJoinGame.get_node("Node2D")
# ## BtnOptionGame
# onready var BtnOptionNode = BtnOptionsGame.get_node("Node2D")

## TirraSprite
onready var TirraSprite = get_node("TirraSprite")
## TirraAnimPlayer
onready var TirraAnimPlayer = get_node("TirraAnimPlayer")
## TirraTween
onready var TirraTween = get_node("TirraTween")

# Where is the pink tirra?
var at_top_position: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TirraTween.connect("tween_completed", self, "_on_tween_completed")
	BtnStartGame.grab_focus()
	BtnStartGame.grab_click_focus()


func _input(_event):
	swap_position()

	# var ui_up = event.is_action_pressed("ui_up")
	# var ui_down = event.is_action_pressed("ui_down")

	# var ui_focus_prev = event.is_action_pressed("ui_focus_prev")
	# var ui_focus_next = event.is_action_pressed("ui_focus_next")

	# if ui_up || ui_focus_next:
	# 	at_top_position+=1
	# 	swap_position()

	# if ui_down || ui_focus_prev:
	# 	at_top_position-=1
	# 	swap_position()


# 	var ui_select = event.is_action_pressed("ui_select")
# 	var ui_accept = event.is_action_pressed("ui_accept")


func swap_position():
	var button = null
	var new_position = TirraSprite.global_position

	if BtnStartGame.has_focus():
		button = BtnStartGame
	elif BtnJoinGame.has_focus():
		button = BtnJoinGame
	elif BtnOptionsGame.has_focus():
		button = BtnOptionsGame

	if !button:
		return

	new_position = button.get_node("Node2D").global_position

	var direction = TirraSprite.global_position.y - new_position.y
	if direction > 0:
		TirraSprite.play("walk_up")
	else:
		TirraSprite.play("walk_down")

	var speed = (TirraSprite.global_position - new_position).length() / 100

	TirraTween.remove_all()

	TirraTween.interpolate_property(
		TirraSprite,
		"global_position",
		TirraSprite.global_position,
		new_position,
		speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)

	TirraTween.start()


func _on_tween_completed(_object: Object, _key: NodePath):
	TirraSprite.play("default")
