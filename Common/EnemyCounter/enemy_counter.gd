##This node should be placed into a scene with enemies as its children to properly work[br]
##signal enemies_defeated should be connected through the inspector to another node's function!
class_name EnemyCounter
extends Node2D

signal enemies_defeated

func _ready() -> void:
	child_exiting_tree.connect(_on_enemy_destroyed)

func _on_enemy_destroyed(node : Node2D) -> void:
	if node is Enemy:
		if enemy_count() <= 1:
			enemies_defeated.emit()
			print(str(name) + " " + "ALL ENEMIES DEFEEATED")
func enemy_count() -> int:
	var _count : int = 0
	for child in get_children():
		if child is Enemy:
			_count += 1
	return _count
