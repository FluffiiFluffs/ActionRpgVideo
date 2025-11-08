class_name PlayerDeathState
extends PlayerState


@export var death_audio: AudioStream
@onready var audio_stream_player_2d = %AudioStreamPlayer2D
@onready var animation_player = %AnimationPlayer


func init() -> void:
	pass

func _ready() -> void:
	pass
	
## What happens when the state is entered
func enter() -> void:
	animation_player.stop()
	animation_player.play("stun_"+player.AnimDirection())
	for child in get_tree().current_scene.get_children():
		if child is Enemy:
			child.queue_free()
	#player.animation_player.play("death")
	#audio plays from animationplayer
	GlobalAudioManager.play_music(null)
	_tween_to_center()
	await get_tree().create_timer(0.5).timeout
	GameOverScreen.play_circle_black()
	#trigger gameover UI
		#gameoverUI plays gameover music
	pass
## What happens when the state is exited
func exit() -> void:
	pass
	
	
## What happens during _process(): update while state is running
func process (_delta : float) -> PlayerState:
	player.velocity = Vector2.ZERO
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> PlayerState:
	return null	
	
## What happens with input events while this state is running
func handle_input( _event: InputEvent) -> PlayerState:
	return null
	
func _tween_to_center()->void:
	var camera:Camera2D
	for child in player.get_children():
		if child is Camera2D:
			camera = child
	var center = camera.get_screen_center_position()
	var tween = player.create_tween()
	tween.tween_property(player,"position",center,1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	
