@tool
@icon("res://ASSETS/Dialogue/quest_advance.png")
class_name QuestAdvanceTrigger
extends QuestNode

@export_category ("PARENT SIGNAL CONNECTION")
@export var signal_name : String = ""

func _ready()->void:
	if Engine.is_editor_hint():
		return
	if signal_name != "":
		if get_parent().has_signal(signal_name):
			get_parent().connect(signal_name, advance_quest)
	$Sprite2D.queue_free()
func advance_quest()->void:
	if linked_quest == null: 
		return
	var _title:String=linked_quest.title
	var _step:String=get_step()
	if _step == "N/A":
		_step = ""
	print("advance_quest " + _title)
	GlobalQuestManager.update_quest(_title, _step, quest_complete)
	
	pass
