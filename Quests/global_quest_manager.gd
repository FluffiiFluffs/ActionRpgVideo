#GLOBAL SCRIPT
#QUEST MANAGER
extends Node

signal quest_updated(q) ##q is a dictionary

#This file needs to ONLY contain quest resource files
const QUEST_DATA_LOCATION:String="res://Quests/quest_data"
#keeps track of all quests in the game
var quests:Array[Quest]

##Array of dictionaries. Dictionaries are in format:[br]
##{title="NOT FOUND", is_complete=false, completed_steps=[""]
var current_quests:Array=[
	#{title="Short Quest", is_complete=false, completed_steps=[""]},
	#{title="Long Quest", is_complete=false, completed_steps=[""]},	
]

func _ready()->void:
#gather all quests
	gather_quest_data()
	pass

#func _unhandled_input(event:InputEvent):
	#if Input.is_action_just_pressed("test1"):
		#print(str(find_quest(load("res://Quests/quest_data/short_quest.tres") as Quest)))
		#print(str(find_quest_by_title("Short Quest")))
		#print ("GET QUEST INDEX BY TITLE: " , get_quest_index_by_title("Short Quest"))
		#print("before", current_quests)
		#print("- - - - - - ")
		#update_quest("Long Quest", "Step 1", false)
		#update_quest("Long Quest", "Step 2", false)
		#update_quest("Long Quest", "Step 3", false)
		#update_quest("Long Quest", "Step 4", false)
		#update_quest("Long Quest", "Step 5", true)
		#update_quest("Short Quest", "Step 1", true)
		#update_quest("Medium Quest", "Step 1", false)
		#update_quest("Medium Quest", "Step 2", false)
		#print("after", current_quests)
		#print("- - - - - - .. - - - - - - ")
		#print(current_quests)
		#pass

##Gathered all quest resource data
func gather_quest_data()->void:
	#finds all files in /quest_data
	var quest_files:PackedStringArray=DirAccess.get_files_at(QUEST_DATA_LOCATION)
	#clears quests array
	quests.clear()
	for q in quest_files:
		#uses the string to load the quest file and appends the name as a string to array as Quest
			quests.append(load(QUEST_DATA_LOCATION + "/" + q) as Quest)
	print("Quests.size() = " + str(quests.size()))
	#print("Quest Resources: "+ str(quests))
	pass

##updates status of a quest [br]
##(adding/starting quest, marking step as complete, marking quest as complete)
func update_quest(_title:String, _completed_step:String="",_is_complete:bool=false)->void:
	var quest_index:int= get_quest_index_by_title(_title)
	#quest was not found, add it to the current_quests array (above function returned -1 to variable)
	#quest is added with completed_steps as empty array, it's a new quest!
	if quest_index == -1:
		var new_quest:Dictionary={
				title=_title, 
				is_complete=_is_complete, 
				completed_steps=[]
			}
		#if player did not have the quest, but has completed a step before getting it...
		if _completed_step != "":
			new_quest.completed_steps.append(_completed_step.to_lower())
		current_quests.append(new_quest)
		quest_updated.emit(new_quest)
		# display notification that a quest was added
		NotifyPanel.queue_notification("QUEST STARTED!", _title)
	#quest was found, update it
	else:
		var q = current_quests[quest_index]
		#if the completed step is emptystring, and the step has not been completed...
		if _completed_step != "" and q.completed_steps.has(_completed_step)==false:
			#add completed step to array
			q.completed_steps.append(_completed_step.to_lower())
		q.is_complete = _is_complete
		quest_updated.emit(q)
		
		if q.is_complete == true:
			NotifyPanel.queue_notification("QUEST COMPLETE!", _title)
			give_quest_rewards(find_quest_by_title(_title))
		else:
			NotifyPanel.queue_notification("QUEST UPDATED!", _title + ": " + _completed_step)
		#display notification that quest updated
		
	pass
	
## gives rewards to player
func give_quest_rewards(_q:Quest)->void:
	#var message:String= 
	for i in _q.reward_items:
		#GlobalPlayerManager.INVENTORY_DATA.add_item(i.item, i.quantity)
		if i.item is ItemData:
			if i.item.use_on_pickup==false:
				GlobalPlayerManager.INVENTORY_DATA.add_item(i.item, i.quantity)
			elif i.item.use_on_pickup==true:
				for item in i.quantity:
					i.item.use()
		NotifyPanel.queue_notification("RECEIVED:",  str(i.item.name) + " x" + str(i.quantity) + "\nfrom " + str(_q.title))
		print("PLAYER GIVEN: ", str(i.item.name), " x", str(i.quantity) + " from " + str(_q.title))
		pass
	pass

##Provided with Quest (resource) and return current quest associated with it.
func find_quest(_quest:Quest)->Dictionary:
	for q in current_quests:
		if q.title.to_lower() == _quest.title.to_lower():
			return q
	return {title="NOT FOUND", is_complete=false, completed_steps=[""]}
	
##finds title and returns Quest Resource
func find_quest_by_title(_title:String)->Quest:
	for q in quests:
		if q.title.to_lower() == _title.to_lower():
			return q
	return null

##Find quest by title name, returns index in current_quests Array
func get_quest_index_by_title(_title:String)->int:
	for i in current_quests.size():
		if current_quests[i].title.to_lower() == _title.to_lower():
			return i
	return -1 #if the quest with the matching title not found, returns -1
	
##sorts quests by...
func sort_quests()->void:
	var active_quests:Array=[]
	var completed_quests:Array=[]
	for q in current_quests:
		if q.is_complete:
			completed_quests.append(q)
		else:
			active_quests.append(q)
	active_quests.sort_custom(sort_quests_ascending)
	completed_quests.sort_custom(sort_quests_ascending)
	current_quests.clear()
	current_quests.append_array(active_quests)
	current_quests.append_array(completed_quests)
	pass

func sort_quests_ascending(a,b):
	if a.title < b.title:
		return true
	return false
