@tool
@icon("res://ASSETS/Icons/cutscene_bubble.svg")
class_name DialogCutscene
extends DialogItem

enum MODE {PARALLEL, SEQUENTIAL}

@export var playback_mode : MODE = MODE.SEQUENTIAL

var actions : Array[CutsceneAction] = []
var actions_finished_count:int = 0

@warning_ignore("unused_signal")
signal started
@warning_ignore("unused_signal")
signal finished

func _ready()->void:
	if Engine.is_editor_hint():
		return
	gather_actions()
	pass
	
	
func _process(_delta)->void:
	#if Engine.is_editor_hint():
		#return
	pass

##Iterates through children of this node and appends children to var actions array
func gather_actions()->void:
	for child in get_children():
		if child is CutsceneAction:
			actions.append(child)
			if Engine.is_editor_hint() == false:
				child.finished.connect(_on_action_finished)

##Plays, depending on parallel or sequential
func play()->void:
	if Engine.is_editor_hint():
		return
	#reset actions finished count...
	actions_finished_count = 0
	if actions.is_empty():
		await get_tree().process_frame
		finished.emit()
	elif playback_mode == MODE.SEQUENTIAL:
		actions[0].play()
	else:
		for act in actions:
			act.play()

				
##What happens when an action finishes.
func _on_action_finished()->void:
	actions_finished_count += 1
	if !actions.is_empty():
		if actions_finished_count >= actions.size():
			finished.emit()
		elif playback_mode == MODE.SEQUENTIAL: #if the playback mode is sequential...
			actions[actions_finished_count].play() #plays next action 
		else:
			for a in actions:
				a.play()
	pass
