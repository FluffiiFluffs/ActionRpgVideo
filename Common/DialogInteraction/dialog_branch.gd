@tool
@icon("res://ASSETS/Icons/answer_bubble.svg")
class_name DialogBranch
extends DialogItem


@export_multiline var text : String = "PLACEHOLDER TEXT"
var dialog_items : Array[DialogItem]

signal selected

func _ready()->void:
	if Engine.is_editor_hint():
		return
	for child in get_children():
		if child is DialogItem:
			dialog_items.append(child)
