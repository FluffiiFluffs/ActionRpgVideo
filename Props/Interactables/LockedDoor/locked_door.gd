class_name LockedDoor
extends Node2D
@onready var static_body_2d = %StaticBody2D
@onready var animation_player = %AnimationPlayer
@onready var audio_stream_player_2d = %AudioStreamPlayer2D
@onready var interaction_area_2d = %InteractionArea2D
@onready var sprite_2d = %Sprite2D
@onready var is_open_data_handler = %IsOpenDataHandler

#What kind of item can open the door
@export var key_item: ItemData 
@export var locked_audio: AudioStream
@export var open_audio: AudioStream

var is_open : bool = false
signal door_opened

func _ready() -> void:
	interaction_area_2d.area_entered.connect(_on_interaction_area_entered)
	interaction_area_2d.area_exited.connect(_on_interaction_area_exited)
	is_open_data_handler.data_loaded.connect(set_state)
	set_state()
	
	
func _on_interaction_area_entered(_area:Area2D) -> void:
	GlobalPlayerManager.interact_pressed.connect(open_door)

func open_door() -> void:
	if key_item == null:
		return
	var door_unlocked = GlobalPlayerManager.INVENTORY_DATA.use_item(key_item)
	if door_unlocked:
		animation_player.play("opening")
		audio_stream_player_2d.stream = open_audio
		is_open_data_handler.set_value()
		await get_tree().process_frame
		door_opened.emit()
	else:
		audio_stream_player_2d.stream = locked_audio
	audio_stream_player_2d.play()
	
func _on_interaction_area_exited(_area:Area2D) -> void:
	GlobalPlayerManager.interact_pressed.disconnect(open_door)

func close_door() -> void:
	animation_player.play("closed")
	
func set_state() -> void:
	is_open = is_open_data_handler.value
	if is_open:
		animation_player.play("opened")
	else:
		animation_player.play("closed")
