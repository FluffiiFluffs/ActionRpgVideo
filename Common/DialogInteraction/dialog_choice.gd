@tool
@icon("uid://brujtgjhde6mk")
class_name DialogChoice
extends DialogItem

#needs at least two branches
var dialog_branches : Array[DialogBranch]

func _ready()->void:
	if Engine.is_editor_hint():
		return
	for child in get_children():
		if child is DialogBranch:
			dialog_branches.append(child)
			


func _get_configuration_warnings()->PackedStringArray:
	#check for dialog branches
	if _check_for_dialog_branches() == false:
		return ["REQUIRES AT LEAST TWO DIALOG BRANCH NODES!"]
	else:
		return []

func _check_for_dialog_branches()->bool:
	var _count:int=0
	for child in get_children():
		if child is DialogBranch:
			_count += 1
			if _count > 1:
				return true
	return false
