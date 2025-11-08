@tool
@icon("res://ASSETS/Icons/star_bubble.svg")
class_name DialogueSystemNode
extends CanvasLayer


@onready var portrait_texture_rect :TextureRect= %PortraitTextureRect
@onready var name_label:Label = %NameLabel
@onready var content:RichTextLabel = %ContentRichTextLabel
@onready var dialog_ui:Control = %DialogUI
@onready var progress_margin_container :MarginContainer= %ProgressMarginContainer
@onready var progress_label:RichTextLabel = %ProgressLabel
@onready var timer:Timer = %Timer
@onready var animation_player:AnimationPlayer = %AnimationPlayer
@onready var audio_stream_player:AudioStreamPlayer = %AudioStreamPlayer
@onready var special_timer:Timer = %SpecialTimer
const CHOICE_BUTTON = preload("uid://bt6ln8hvaals3")
@onready var choice_options = %ChoiceVBoxContainer

signal started
signal finished
#signal letter_added(letter:String)

var is_active : bool = false
var text_in_progress:bool = false
var text_speed:float=0.03
var text_length:int=0
var plain_text:String
var dialog_items:Array[DialogItem]
var dialog_item_index: int = 0
var speaker_portrait:Texture
var speaker_talk:Texture
var speaker_special:Texture
var waiting_for_choice:bool=false
var current_dialog_text:DialogText
var cutscene_in_progress:bool=false


func _ready() -> void:
	if Engine.is_editor_hint():
		if get_viewport() is Window:
			get_parent().remove_child(self)
			return
		return
	# keep the dialog running during global pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	special_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	animation_player.process_mode = Node.PROCESS_MODE_ALWAYS
	audio_stream_player.process_mode = Node.PROCESS_MODE_ALWAYS

	hide_dialog()
	timer.timeout.connect(_on_timer_timeout)
	special_timer.timeout.connect(_on_special_timer_timeout)




func _process(_delta:float)->void:
	if text_in_progress:
		if content.visible_characters % 4:
			if speaker_portrait != null:
				if speaker_talk != null:
					if " ".contains(plain_text[content.visible_characters - 1]):
						return
					portrait_texture_rect.texture = speaker_talk
				else:
					portrait_texture_rect.texture = speaker_portrait
		elif !content.visible_characters % 4:
			if speaker_portrait != null:
				portrait_texture_rect.texture = speaker_portrait
			else:
				portrait_texture_rect.texture = null


		
func _unhandled_input(_event)->void:
	#prevents talking if pause menu or inventory menu is open or opening
	#inventory cannot open when talking, but just to be safe...
	if (is_active == false or 
		PauseMenu.menu_is_open or 
		InventoryMenu.inventory_is_open or 
		PauseMenu.menu_is_animating or 
		InventoryMenu.inventory_is_animating or
		cutscene_in_progress == true):
		return
	elif (
		Input.is_action_just_pressed("cancel_input") #or
		#Input.is_action_just_pressed("confirm_input") or
		#Input.is_action_just_pressed("ui_accept")
	):
		#allows player to hit button to skip text
		if text_in_progress == true:
			timer.stop()
			text_in_progress = false
			show_dialog_button_indicator(true)
			content.visible_characters = text_length
			return #this is really important, otherwise the text skips
	elif Input.is_action_just_pressed("ui_accept"):
		if waiting_for_choice == true:
			return
		if text_in_progress == false:
			advance_dialog()
			await get_tree().create_timer(0.3,true).timeout

##Allows dialog to be advanced separately from user input...or from user input
func advance_dialog()->void:
		dialog_item_index += 1
		if dialog_item_index < dialog_items.size():
			start_dialog()
		else:
			hide_dialog()

func show_dialog(_items: Array[DialogItem])->void:
	# already showing a dialog, do not reset items or index
	if is_active:
		get_tree().paused = true
		return
	if _items[0] is DialogCutscene:
		dialog_ui.visible = false
	else:
		dialog_ui.visible = true
	name_label.text = ""
	content.text = ""
	portrait_texture_rect.texture = null
	# only set index to 0 on the very first open
	if is_active == false:
		dialog_item_index = 0
	is_active = true
	dialog_ui.visible = true
	dialog_items = _items
	get_tree().paused = true
	started.emit()
	if dialog_items.size() == 0: ##fix from the video, may mess stuff up
		hide_dialog()
	else:
		start_dialog()
	#start_dialog()

func start_dialog_cutscene(_dc : DialogCutscene)->void:
	cutscene_in_progress = true
	_dc.play()
	#hide choices and dialog UI
	choice_options.visible = false
	dialog_ui.visible = false
	await _dc.finished #waits for cutscene to finish
	#unhide choices and dialog UI
	#choice_options.visible = true
	dialog_ui.visible = true
	cutscene_in_progress = false
	advance_dialog()
	pass


func start_dialog() -> void:
	waiting_for_choice = false
	show_dialog_button_indicator(false)

	if dialog_item_index < 0 or dialog_item_index >= dialog_items.size():
		hide_dialog()
		return

	var _dialogitem = dialog_items[dialog_item_index]
	if _dialogitem is DialogText:
		set_dialog_text(_dialogitem)
	elif _dialogitem is DialogChoice:
		set_dialog_choice(_dialogitem)
	elif _dialogitem is DialogCutscene:
		start_dialog_cutscene(_dialogitem)	
	if PauseMenu.voices_enabled == false:
		audio_stream_player.play()

##setting the dialog choice UI based on parameters	
func set_dialog_choice(_dialogitem:DialogItem)->void:
	choice_options.visible = true
	waiting_for_choice = true
	for child in choice_options.get_children():
		child.queue_free()
	for i in _dialogitem.dialog_branches.size():
		var _new_choice = CHOICE_BUTTON.instantiate()
		_new_choice.text  = _dialogitem.dialog_branches[i].text
		_new_choice.pressed.connect(_dialog_choice_selected.bind(_dialogitem.dialog_branches[i]))
		choice_options.add_child(_new_choice)
	await get_tree().process_frame	
	await get_tree().process_frame	
	choice_options.get_child(0).grab_focus()

func _dialog_choice_selected(_dialog_branch: DialogBranch) -> void:
	# close the choice UI
	waiting_for_choice = false
	choice_options.visible = false
	for child in choice_options.get_children():
		child.queue_free()

	# load the branch safely without restarting the whole dialog
	dialog_items = _dialog_branch.dialog_items
	dialog_item_index = 0
	_dialog_branch.selected.emit()
	start_dialog()

	
func set_dialog_text(_dialogitem: DialogItem)->void:
	content.text = _dialogitem.text
	current_dialog_text = _dialogitem
	if _dialogitem == DialogText:
		_dialogitem = current_dialog_text
	if _dialogitem.npc_info:
		if _dialogitem.npc_info.npc_name:
			name_label.text = _dialogitem.npc_info.npc_name
		elif !_dialogitem.npc_info.npc_name:
			name_label.text = ""
		if _dialogitem.npc_info.portrait:
			portrait_texture_rect.texture = _dialogitem.npc_info.portrait
			speaker_portrait = _dialogitem.npc_info.portrait
		elif !_dialogitem.npc_info.portrait:
			portrait_texture_rect.texture = null
			speaker_portrait = null
		if _dialogitem.npc_info.portrait_talk:
			speaker_talk = _dialogitem.npc_info.portrait_talk
		elif !_dialogitem.npc_info.portrait_talk:
			speaker_talk = null
		if _dialogitem.npc_info.portrait_special:
			speaker_special = _dialogitem.npc_info.portrait_special
		elif !_dialogitem.npc_info.portrait_special:
			speaker_special = null
		if _dialogitem.npc_info.dialog_voice:
			audio_stream_player.stream = _dialogitem.npc_info.dialog_voice
		elif !_dialogitem.npc_info.dialog_voice:
			audio_stream_player.stream = null
		if _dialogitem.npc_info.dialog_audio_pitch:
			audio_stream_player.pitch_scale = _dialogitem.npc_info.dialog_audio_pitch
		elif !_dialogitem.npc_info.dialog_audio_pitch:
			audio_stream_player.pitch_scale = 1.0
	elif !_dialogitem.npc_info:
		name_label.text = ""
		speaker_portrait = null
		speaker_special = null
		speaker_talk = null
		portrait_texture_rect.texture = null
		audio_stream_player.stream = null
		audio_stream_player.pitch_scale = 1.0	
	content.visible_characters = 0
	text_length = content.get_total_character_count()
	plain_text = content.get_parsed_text()
	text_in_progress = true
	special_timer.stop()
	start_timer()
		

func start_timer()->void:
	if content.visible_characters - 1 == -1:
		text_speed = 0.03
	if content.visible_characters -1 >= 0:
		if "?,!:".contains(plain_text[content.visible_characters - 1]):
			text_speed = 0.2
		elif ".".contains(plain_text[content.visible_characters - 1]):
			text_speed = 0.3
		elif " ".contains(plain_text[content.visible_characters - 1]):
			text_speed = 0.05
		elif !"?.,!:".contains(plain_text[content.visible_characters - 1]):
			text_speed = 0.03
	timer.wait_time = text_speed
	timer.start()

func _on_timer_timeout()->void:
	#print(str(plain_text[content.visible_characters - 1]))
	if (PauseMenu.menu_is_open):
		start_timer()
		return
	elif (InventoryMenu.inventory_is_open):
		start_timer()
		return
			
	elif content.visible_characters < text_length:
		content.visible_characters +=1
		start_timer()
		if " ".contains(plain_text[content.visible_characters - 1]):
			return
		if PauseMenu.voices_enabled == true:
			audio_stream_player.play()
	elif content.visible_characters == text_length:
		portrait_texture_rect.texture = speaker_portrait
		timer.stop()
		text_in_progress = false
		show_dialog_button_indicator(true)
		

func _on_special_timer_timeout()->void:
	if text_in_progress == false:
		if speaker_special != null:
			portrait_texture_rect.texture = speaker_special
			await get_tree().create_timer(0.75).timeout
			portrait_texture_rect.texture = speaker_portrait
		if speaker_special == null:
			portrait_texture_rect.texture = speaker_portrait
		special_timer.wait_time = randf_range(3.3, 5.5)
	special_timer.start()
	#elif text_in_progress == true:
		#special_timer.stop()
	

	
func show_dialog_button_indicator(_is_visible:bool)->void:
	progress_margin_container.visible = _is_visible
	#if there is one more dialog item after this one...
	if dialog_item_index +1 < dialog_items.size():
		special_timer.wait_time = randf_range(1.2, 2.5)
		special_timer.start()
		progress_label.text = "[wave]NEXT[/wave]"
	else:
		progress_label.text = "[wave]END[/wave]"
		special_timer.wait_time = randf_range(1.2, 2.5)
		special_timer.start()
	
func hide_dialog()->void:
	#name_label.text == ""
	#content.text = ""
	#portrait_texture_rect.texture = null
	show_dialog_button_indicator(false)
	is_active = false
	choice_options.visible = false
	dialog_ui.visible = false
	get_tree().paused = false
	NotifyPanel.display_notification()
	if current_dialog_text != null:
		current_dialog_text.dialogtextfinished.emit()
	finished.emit()
