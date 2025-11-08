extends Node


	
func light_torches()->void:
	for child in get_tree().current_scene.get_children():
		if child is Torch:
			child.is_lit = true
