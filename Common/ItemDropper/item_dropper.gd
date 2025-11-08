@tool
class_name ItemDropper
extends Node2D

@onready var label = %Label
@onready var audio_stream_player = %AudioStreamPlayer
@onready var sprite_2d = %Sprite2D
@onready var has_dropped_data_handler = %HasDroppedDataHandler

const PICKUP = preload("uid://cbpnajsqw23v8") #Item Pickup Scene

@export var item_data : ItemData : set = _set_item_data

var has_dropped : bool = false

func _ready()->void:
	if Engine.is_editor_hint():
		_update_texture()
		return
	sprite_2d.visible = false
	has_dropped_data_handler.data_loaded.connect(_on_data_loaded)
	_on_data_loaded()


func drop_item() -> void:
	if has_dropped:
		return
	has_dropped = true
	var drop = PICKUP.instantiate() as ItemPickup
	drop.item_data = item_data
	add_child(drop)
	#This signal emitted from function item_picked_up() in ItemPickup.gd
	#lambda function places a value in GlobalSaveManager.current_save["player"]["perisistence"] array
	drop.picked_up.connect(func _on_drop_picked_up(): has_dropped_data_handler.set_value())
	drop.animation_player.play("bounce")
	audio_stream_player.play()
	


func _set_item_data(item : ItemData) -> void:
	item_data = item
	_update_texture()
	
func _update_texture() -> void:
	if Engine.is_editor_hint():
		if item_data and sprite_2d:
			sprite_2d.texture = item_data.texture

func _on_data_loaded()->void:
	has_dropped = has_dropped_data_handler.value
	
