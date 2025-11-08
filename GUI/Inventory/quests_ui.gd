##Responsible for populating quest list, and updating the display.
class_name QuestsUI
extends Control

@onready var quests_v_box = %QuestsVBoxContainer #Quest Item Container
@onready var q_title_label = %QTitleLabel
@onready var q_description_label = %QDescriptionLabel
@onready var q_details_box = %QDetailsVBoxContainer
@onready var qdh_separator_2 = %QDHSeparator2
@onready var qdh_separator_3 = %QDHSeparator3

const QUEST_ITEM : PackedScene = preload("uid://b24sdupginlei")
const STEP_ITEM :PackedScene = preload("uid://dfbwjfqfdqw7e")

func _ready()->void:
	clear_quest_details()
	visibility_changed.connect(_on_visible_changed) #when this tab becomes visible...
	pass
	

func _on_visible_changed()->void:
	qdh_separator_2.visible = false
	qdh_separator_3.visible = false
	for child in quests_v_box.get_children():
		child.queue_free()
	clear_quest_details()
	if visible: #update the list
		GlobalQuestManager.sort_quests()
		for q in GlobalQuestManager.current_quests:
			var quest_data : Quest = GlobalQuestManager.find_quest_by_title(q.title) #stores quest found, by title
			if quest_data == null: #if not found...
				printerr(GlobalQuestManager.find_quest_by_title(q.title), " NOT FOUND")
				continue #go to next item in loop
			var new_q_item: QuestItem = QUEST_ITEM.instantiate() #if no error, then instance a new quest_item.tscn
			quests_v_box.add_child(new_q_item) #adds instance as child of quest vbox
			 #uses data from Quest object to fill out the child's info...
			new_q_item.initialize(quest_data, q)
			#connect on focus entered...
			new_q_item.focus_entered.connect(update_quest_details.bind(new_q_item.quest))
	pass

func update_quest_details(q:Quest)->void:
	#clear previous details
	clear_quest_details()
	q_title_label.text = q.title
	q_description_label.text = q.description
	var quest_save = GlobalQuestManager.find_quest(q)
	for step in q.steps:
		var new_step : QuestStepItem = STEP_ITEM.instantiate()
		var step_is_complete:bool=false
		if quest_save.title != "NOT FOUND":
			step_is_complete = quest_save.completed_steps.has(step.to_lower())
		q_details_box.add_child(new_step)
		new_step.initialize(step, step_is_complete)
	qdh_separator_2.visible = true
	qdh_separator_3.visible = true
	pass
	
	
func clear_quest_details()->void:
	qdh_separator_2.visible = false
	qdh_separator_3.visible = false
	q_title_label.text = ""
	q_description_label.text = ""
	for child in q_details_box.get_children():
		if child is QuestStepItem:
			child.queue_free()
