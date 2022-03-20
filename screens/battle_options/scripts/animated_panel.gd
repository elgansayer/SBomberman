extends Panel

var sprite_pool: Array[Sprite2D] = []
@export var bomb_texture: Texture;

var use_pos_one: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var vector_direction = Vector2(1, 1)
	var speed = 70
	for sprite in sprite_pool:
		if sprite.get_parent() != self:
			continue
			
		var motion = vector_direction * speed 
		var new_position = sprite.position - motion * delta
		sprite.position = new_position
	
	var removed_items: Array[int] = []
	for i in range(sprite_pool.size()):
		var sprite = sprite_pool[i]
		if sprite.position < Vector2(-50, 0):
			removed_items.append(i)
			
	for p in removed_items:
		var sprite = sprite_pool[p]
		sprite_pool.erase(sprite)
		remove_child(sprite)
		sprite.queue_free()	
		
func spawn_line():
	var size = self.get_size() 
	var position_offset: Vector2 = Vector2(-450, 450)
	if !use_pos_one:
		position_offset = Vector2(-150, 150) #Vector2(-225, 125)
		
	var start_point = size + position_offset
	
	var distance_between = Vector2(125, -125)
		
	for  n in 6:
		var sprite = spawn_sprite()		
		sprite_pool.append(sprite)
		var offset = distance_between * n 
		sprite.position = start_point + offset
		
	use_pos_one = !use_pos_one
	
func spawn_sprite():
	var sprite = Sprite2D.new()
	sprite.texture = bomb_texture
	add_child(sprite)
	return sprite


func _on_timer_timeout():
	spawn_line()
