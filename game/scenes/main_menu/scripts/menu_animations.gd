extends Node2D

@export var buttons: Array[NodePath] = []
@export var tirra_sprite: NodePath
@onready var tirraSprite: AnimatedSprite2D = get_node(tirra_sprite)

# Where is the pink tirra?
var last_button: Button =  null;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	swap_position()

func _input(_event: InputEvent):
	swap_position()

func swap_position():
	if !tirraSprite:
		return
		
	var selected_button = null
	var new_position = tirraSprite.global_position

	for node_path in buttons:
		if get_node(node_path).has_focus():
			selected_button = get_node(node_path)

	if !selected_button:
		return

	if last_button == selected_button:
		return

	last_button = selected_button
	
	new_position = selected_button.get_node("Node2D").global_position

	var speed = (tirraSprite.global_position - new_position).length() / 100
	var tween = get_tree().create_tween()
	
	if speed <= 0:
		return

	var direction = tirraSprite.global_position.y - new_position.y
	if direction > 0:
		tirraSprite.play("walk_up")
	else:
		tirraSprite.play("walk_down")

	tween.tween_property(
		tirraSprite,
		"global_position",
		new_position,
		speed
	)	
	tween.tween_callback(_on_tween_completed)

	tween.play()

	flash_btn_white(selected_button)

	$FlashTimer.stop()
	flash_button(selected_button)

func flash_button(selected_button):
	var timer = Timer.new()
	timer.connect("timeout", _on_btn_touch_timeout, [selected_button] ) 
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer) 
	timer.start()
	$FlashTimer.start()


func _on_btn_touch_timeout(selected_button):
	var flash_value = 0.0
	self.set_shader_flash(selected_button, flash_value)


func _on_tween_completed():
	tirraSprite.stop()
	tirraSprite.play("default")


func set_shader_flash(selected_button, flash_value):
	var btnSpriteMaterial = selected_button.get_material()
	btnSpriteMaterial.set_shader_param("white_value", flash_value)


func flash_btn_white(_selected_button):
	var flash_value = 0.5
	self.set_shader_flash(last_button, flash_value)	


func _on_flash_timer_timeout():
	if !last_button:
		return

	flash_btn_white(last_button)
	flash_button(last_button)
