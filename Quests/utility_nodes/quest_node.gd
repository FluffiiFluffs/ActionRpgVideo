@tool
class_name QuestNode
extends Node2D

#set functions are for updating information via @tool in the editor....
@export var linked_quest : Quest = null :set = _set_quest
@export var quest_step:int=0 : set = _set_step
@export var quest_complete:bool = false : set = _set_complete

@export_category("INFORMATION ONLY")
@export_multiline var settings_summary : String

func _set_quest(_quest : Quest)->void:
	linked_quest = _quest
	quest_step = 0
	update_summary()


#updates settings_summary
func update_summary()->void:
	settings_summary = "UPDATE QUEST: \nQuest: " + linked_quest.title + "\n"
	settings_summary += "Step: " + str(quest_step) + " - " + get_step() + "\n"
	settings_summary += "Complete: " + str(quest_complete)
	
	pass
#make sure step is in the actual range of steps
func get_step()->String:
	if quest_step != 0 and quest_step <= get_steps_count() :
		return linked_quest.steps[quest_step-1].to_lower()
	else:
		return "N/A"
func _set_step(_step:int)->void:
	quest_step = clamp(_step, 0, get_steps_count())
	update_summary()
	pass

#determines how many steps are in the quest
func get_steps_count()->int:
	if linked_quest == null: #there's no quest...
		return 0
	else:
		return linked_quest.steps.size() #return size of steps array

func _set_complete(_value:bool)->void:
	quest_complete = _value
	update_summary()
	pass


func get_prev_step() -> String:
	if quest_step <= get_step_count() and quest_step > 1:
		return linked_quest.steps[ quest_step - 2 ]
	else:
		return "N/A"

func get_step_count() -> int:
	if linked_quest == null:
		return 0
	else:
		return linked_quest.steps.size()
