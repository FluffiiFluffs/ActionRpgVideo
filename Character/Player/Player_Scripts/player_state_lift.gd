class_name PlayerStateLift
extends PlayerState


@export var lift_sfx:AudioStream
@onready var carry :PlayerState= %Carry
@onready var animation_player:AnimationPlayer = %AnimationPlayer
@onready var audio_stream_player_2d:AudioStreamPlayer2D = %AudioStreamPlayer2D

var is_lifting:bool=false

func init() -> void:
	pass


func _ready() -> void:
	pass
	
## What happens when the state is entered
func enter() -> void:
	is_lifting = true
	player.update_animation("lift")
	if !animation_player.animation_finished.is_connected(_state_complete):
		animation_player.animation_finished.connect(_state_complete)
	audio_stream_player_2d.stream = lift_sfx
	audio_stream_player_2d.play()

	
	
## What happens when the state is exited
func exit() -> void:
	if animation_player.animation_finished.is_connected(_state_complete):
			animation_player.animation_finished.disconnect(_state_complete)
	is_lifting = false
	pass
#
#func set_prop()->void:
	#var _marker_children = GlobalPlayerManager.player.held_item_marker_2d.get_children()
	#for child in _marker_children:
		#if child is Throwable:
			#var _held_prop = child.get_parent()
			#GlobalPlayerManager.player.held_prop = _held_prop
			#
	
	
## What happens during _process(): update while state is running
func process (_delta : float) -> PlayerState:
	if is_lifting:
		player.velocity = Vector2.ZERO
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> PlayerState:
	return null	
	
## What happens with input events while this state is running
func handle_input( _event: InputEvent) -> PlayerState:
	return null

func _state_complete(_anim_name:String)->void:
	is_lifting = false
	animation_player.animation_finished.disconnect(_state_complete)
	state_machine.change_state(carry)
