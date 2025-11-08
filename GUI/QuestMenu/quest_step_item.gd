class_name QuestStepItem
extends Control


@onready var unchecked = %Unchecked
@onready var checked = %Checked
@onready var label = %Label

func initialize(step:String, is_complete:bool)->void:
	label.text = step
	if is_complete:
		unchecked.visible = false
		checked.visible = true
	else:
		unchecked.visible = true
		checked.visible = false
