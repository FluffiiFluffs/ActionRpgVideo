@tool
class_name Torch
extends Node2D

@export var is_lit: bool = true:
	set = _set_torch_light, get = _get_torch_light

var _is_lit: bool = true
const FIRE = preload("uid://b083ed2rrs1go")

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var area_2d = %Area2D
@onready var audio_stream_player_2d = %AudioStreamPlayer2D
@onready var tile_map_layer = %TileMapLayer


func _ready() -> void:
	#syncs exported value 
	_is_lit = is_lit 
	#turns torch on or off depending on the value
	_apply_torch_anim()
	if Engine.is_editor_hint():
		return
	tile_map_layer.queue_free()
	area_2d.area_entered.connect(_on_area_entered)
	area_2d.area_exited.connect(_on_area_exited)
	


func _set_torch_light(value: bool) -> void:
	if _is_lit == value:
		return
	_is_lit = value
	_apply_torch_anim()


func _get_torch_light() -> bool:
	return _is_lit


func _apply_torch_anim() -> void:
	if animation_player == null:
		return
	if _is_lit:
		#print(str(name)+" turned on")
		animation_player.play("lit")
	else:
		#print(str(name)+" turned off")
		animation_player.play("off")

func _toggle_torch()->void:
	if is_lit == false:
		audio_stream_player_2d.stream = FIRE
		audio_stream_player_2d.play()
		is_lit = true
	else:
		is_lit = false

func _on_area_entered(_area:Area2D)->void:
	if !GlobalPlayerManager.interact_pressed.is_connected(_toggle_torch):
		GlobalPlayerManager.interact_pressed.connect(_toggle_torch)
	
	
func _on_area_exited(_area:Area2D)->void:
	if GlobalPlayerManager.interact_pressed.is_connected(_toggle_torch):
		GlobalPlayerManager.interact_pressed.disconnect(_toggle_torch)
	pass
