class_name BarredDoor
extends Node2D


@onready var animation_player = %AnimationPlayer
const DOOR_OPEN = preload("uid://mxhdtrlrk7yq")
const DOOR_CLOSE = preload("uid://drg7obs8rfjm1")
@onready var audio_stream_player_2d = %AudioStreamPlayer2D


var is_open : bool = false
signal door_just_opened

func _ready() -> void:
	pass

##This function is connected to a pressure plate's body_entered signal through the inspector.[br]
##signal activated
func open_door() -> void:
	if GlobalSaveManager.is_loading:
		await GlobalSaveManager.game_loaded
	audio_stream_player_2d.stream = DOOR_OPEN
	audio_stream_player_2d.play()
	animation_player.play("opening")
	get_tree().paused = true
	await animation_player.animation_finished
	get_tree().paused = false
	animation_player.play("opened")
	is_open = true
	door_just_opened.emit()
##This function is connected to a pressure plate's body_entered signal through the inspector.[br]
##signal deactivated
func close_door() -> void:
	if GlobalSaveManager.is_loading:
		await GlobalSaveManager.game_loaded
	audio_stream_player_2d.stream = DOOR_CLOSE
	audio_stream_player_2d.play()
	animation_player.play("closing")
	get_tree().paused = true
	await animation_player.animation_finished
	get_tree().paused = false
	animation_player.play("closed")
	is_open = false


func _on_boss_01_boss_is_gone():
	open_door()
