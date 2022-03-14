extends Node2D

func _on_timer_timeout():
	var node = get_node("Node2D")
	var patch = node.get_node("NinePatchBorder")
	patch.visible = !patch.visible
