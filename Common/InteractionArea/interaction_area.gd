@tool
class_name InteractionArea
extends Area2D

enum InteractionType { EXCLAIM, QUESTION, NONE }

@export var enabled : bool = true
@export var interaction_type: InteractionType = InteractionType.QUESTION
#var dialog_items : Array[DialogItem]
var was_interacted_with:bool=false

signal finished
signal player_interacted

func _ready()->void:
	if Engine.is_editor_hint():
		return
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)	
	#for child in get_children():
		#if child is DialogItem:
			#dialog_items.append(child)
	
			
			
func _get_configuration_warnings()->PackedStringArray:
	#check for dialog items
	if _check_for_collision_shape() == false:
		return ["NEEDS COLLISION SHAPE!!"]
	else:
		return []

func _check_for_collision_shape()->bool:
	for child in get_children():
		if child is CollisionShape2D:
			return true
	return false

func player_interact()->void:
	GlobalPlayerManager.player.interaction_animation_player.play("BLANK")
	was_interacted_with = true
	await get_tree().process_frame
	player_interacted.emit()
	#DialogSystem.show_dialog(dialog_items)
	#if !DialogSystem.finished.is_connected(_on_dialog_finished):
		#DialogSystem.finished.connect(_on_dialog_finished)
	
#func _on_dialog_finished()->void:
	#DialogSystem.finished.disconnect(_on_dialog_finished)
	#if interaction_type == InteractionType.QUESTION:
		#GlobalPlayerManager.player.interaction_animation_player.play("QuestionPopUp")
	#elif interaction_type == InteractionType.EXCLAIM:
		#GlobalPlayerManager.player.interaction_animation_player.play("ExclaimPopUp")
	#elif interaction_type == InteractionType.NONE:
		#return
	#finished.emit()

func _on_area_entered(_area:Area2D)->void:
	was_interacted_with = false
	#if enabled == false or dialog_items.size() == 0:
	if enabled == false:
		return
	GlobalPlayerManager.interact_pressed.connect(player_interact)
	if interaction_type == InteractionType.QUESTION:
		GlobalPlayerManager.player.interaction_animation_player.play("QuestionPopUp")
	elif interaction_type == InteractionType.EXCLAIM:
		GlobalPlayerManager.player.interaction_animation_player.play("ExclaimPopUp")
	elif interaction_type == InteractionType.NONE:
		return
		
func _on_area_exited(_area:Area2D)->void:
	GlobalPlayerManager.interact_pressed.disconnect(player_interact)
	if was_interacted_with == true:
		GlobalPlayerManager.player.interaction_animation_player.play("BLANK")
	elif interaction_type == InteractionType.QUESTION:
		GlobalPlayerManager.player.interaction_animation_player.play("QuestionPopDown")
	elif interaction_type == InteractionType.EXCLAIM:
		GlobalPlayerManager.player.interaction_animation_player.play("ExclaimPopDown")
	elif interaction_type == InteractionType.NONE:
		return




#func gather_interactables()->void:
	#for child in get_children():
		#if child is DialogInteraction:
			#child.player_interacted.connect(_on_player_interacted)
			#child.finished.connect(_on_interaction_finished)
			#
#func _on_player_interacted()->void:
	##npc_state_machine.change_state(talk)
	#pass
#func _on_interaction_finished()->void:
	##update_animation()
	#pass
