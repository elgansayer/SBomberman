extends Control

## BtnHostGame
@onready var BtnHostGame = get_node("BtnHostGame")
## BtnJoinGame
@onready var BtnJoinGame = get_node("BtnJoinGame")
## BtnOptionsGame
@onready var BtnOptionsGame = get_node("BtnOptionsGame")

# Where is the pink tirra?
var at_top_position: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# tween.connect("tween_completed", _on_tween_completed)
	BtnHostGame.grab_focus()
	BtnHostGame.grab_click_focus()
	swap_position()


func _input(_event: InputEvent) -> void:
	swap_position()


func swap_position():
	var button = null
	var new_position = $TirraSprite.global_position

	if BtnHostGame.has_focus():
		button = BtnHostGame
	elif BtnJoinGame.has_focus():
		button = BtnJoinGame
	elif BtnOptionsGame.has_focus():
		button = BtnOptionsGame

	if !button:
		return

	new_position = button.get_node("Node2D").global_position

	var direction = $TirraSprite.global_position.y - new_position.y
	if direction > 0:
		$TirraSprite.play("walk_up")
	else:
		$TirraSprite.play("walk_down")

	var speed = ($TirraSprite.global_position - new_position).length() / 100

	var tween = get_tree().create_tween()
	# tween.tween_property($Sprite, "modulate", Color.red, 1)
	# tween.tween_property($Sprite, "scale", Vector2(), 1)
	# tween.tween_callback($Sprite.queue_free)
		
	# tween.tween_property("global_position:x", $TirraSprite.x, 1).as_relative()
	# tween.tween_callback(jump)
	# tween.tween_interval(2)
	# tween.tween_property("global_position:y", $TirraSprite.y, 1).as_relative()
	# tween.tween_callback(jump)
	# tween.tween_interval(2)

	# tween.interpolate_value(
	# 	$TirraSprite,
	# 	"global_position",
	# 	$TirraSprite.global_position,
	# 	new_position,
	# 	speed,
	# 	Tween.TRANS_LINEAR
	# )

	tween.tween_property(
		$TirraSprite,
		"global_position",
		new_position,
		speed
	)	
	tween.play()


func _on_tween_completed(_object: Object, _key: NodePath):
	$TirraSprite.play("default")


func _on_btn_host_game_pressed():
	pass # Replace with function body.
