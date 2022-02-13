extends Sprite
## Nodes
onready var world = get_node("/root/World")

var been_used: bool = false
var follow_node
var going_direction 
var start_location

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_physics_process(false)


func constructor(node_to_follow, direction):
	self.global_position = node_to_follow.global_position
	self.follow_node = node_to_follow
	self.set_physics_process(true)
	self.going_direction = direction
	start_location = self.global_position

	if self.going_direction != world.orientation.Horizontal:
		destroy()

func destroy():
	self.set_physics_process(false)
	self.queue_free()


func update_position():
	var node_location = self.follow_node.global_position

	if self.going_direction == world.orientation.Horizontal:
		self.global_position.x = node_location.x
		var distance = self.global_position.y - node_location.y
		return distance
	else:
		#TODO: Fix shadows veritcal
		return 0
		# var distance = start_location.y - node_location.y
		# self.global_position.y = node_location.y
		# return distance


func _physics_process(_delta_time: float):
	var distance = update_position()

	var mlti = world.grid_size / 2
	var scale = distance / mlti  #32
	scale = min(scale, 2.9)
	scale = max(scale, 0)

	self.scale = Vector2(scale, scale)

	print(distance," ", scale)

	if distance <= 0 && been_used:
		self.destroy()
	elif distance > 1:
		been_used = true
