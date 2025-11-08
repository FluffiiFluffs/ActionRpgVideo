class_name PushableStatue
extends RigidBody2D

@onready var persistent_data_handler = %PersistentDataHandler

##The sound being used for this needed to be reimported with loop_mode FORWARD
@onready var audio_stream_player_2d = %AudioStreamPlayer2D
##How quickly the statue moves when pushed by the player
@export var push_speed : float = 30.0
##If true, location of the statue can be saved
@export var persistent:bool=false
##Used to set the location of the statue when its location has been saved
@export var target_loc:Node2D=null

var push_direction : Vector2 = Vector2.ZERO : set = _set_push
var location_is_saved:bool=false
var can_be_pushed:bool=true

func _ready()->void:
	_on_data_loaded()
	if persistent==true:
		if location_is_saved == true:
			if target_loc != null:
				global_transform = target_loc.global_transform
	pass

func _physics_process(_delta:float) -> void:
	if can_be_pushed == true:
		if GlobalPlayerManager.is_moving:
			linear_velocity = push_direction * push_speed
			if linear_velocity != Vector2.ZERO:
				if not audio_stream_player_2d.playing: audio_stream_player_2d.play()
			else:
				if audio_stream_player_2d.playing: audio_stream_player_2d.stop()
		elif !GlobalPlayerManager.is_moving:
			linear_velocity = Vector2.ZERO
			if audio_stream_player_2d.playing: audio_stream_player_2d.stop()
	else:
		linear_velocity = Vector2.ZERO
		if audio_stream_player_2d.playing: audio_stream_player_2d.stop()
			
func _set_push(value:Vector2) -> void:
	push_direction = value
	
##This needs to be called by a signal when the statue reaches a position[br]
##Don't forget to setup the export target_loc in the inspector![br]
##Target loc can be anything, must be Node2D. Null by default!
func save_location()->void:
	persistent_data_handler.set_value()
	can_be_pushed = false
	
func _on_data_loaded()->void:
	location_is_saved = persistent_data_handler.value
	can_be_pushed = not persistent_data_handler.value
