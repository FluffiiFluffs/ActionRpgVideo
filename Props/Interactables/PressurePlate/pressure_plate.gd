##Detects bodies (enemies, wall, and player).[br]
##When a body enters the area, the bodies variable is incremented.[br]
##The switch only deactivates when bodies is 0[br]
##this prevents the switch from deactivating at weird times if more than one body is present.
##The activated and deactivated signals need to be connected through the inspector.[br]
##See BarredDoor and Level01D01 for examples of connection.
class_name PressurePlate
extends Node2D

signal activated
signal deactivated
signal activated_by_statue

var bodies :int= 0
var is_active : bool = false
var deactivated_rect : Rect2 = Rect2(417,65,30,30)
var activated_rect : Rect2 = Rect2(385,65,30,30)

@onready var area_2d:Area2D = %Area2D
@onready var sprite_2d = %Sprite2D
@onready var audio_stream_player_2d = %AudioStreamPlayer2D
@onready var button_sound : AudioStream = preload("uid://bss1e4t3hc5d0")

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	sprite_2d.texture.region = deactivated_rect
	
func _on_body_entered(_body:Node2D) -> void:
	bodies += 1
	check_is_activated()
	if _body is PushableStatue:
		activated_by_statue.emit()

func _on_body_exited(_body:Node2D) -> void:
	bodies -= 1
	check_is_activated()


func check_is_activated() -> void:
	if bodies > 0 and !is_active:
		is_active = true
		sprite_2d.texture.region = activated_rect
		activated.emit()
		audio_stream_player_2d.stream = button_sound
		audio_stream_player_2d.play()
	elif bodies <= 0 and is_active:
		is_active = false
		sprite_2d.texture.region = deactivated_rect
		deactivated.emit()
		audio_stream_player_2d.stream = button_sound
		audio_stream_player_2d.play()
