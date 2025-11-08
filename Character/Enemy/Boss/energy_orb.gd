class_name EnergyOrb
extends Node2D

@onready var hurt_box = %HurtBox
@onready var audio_stream_player_2d = %AudioStreamPlayer2D
@onready var animation_player = %AnimationPlayer
const SHOOT = preload("uid://m752yfpmq213")
const CHARGE = preload("uid://blv5pa7glsy2y")
const SHOCK = preload("uid://cr34feejhxmic")
@onready var timer = %Timer

@export var speed:float=250.00

var direction:Vector2=Vector2.DOWN
var charge_time:float=1.5
var is_charging:bool=false
var is_chasing:bool=false
var target:Vector2=Vector2.ZERO
var move_direction:Vector2=Vector2.ZERO
func _ready()->void:

	hurt_box.touched_something.connect(_on_touched_something)
	charging()

func _process(delta)->void:
	if is_charging:
		return
	elif is_chasing:
		global_position += move_direction * speed * delta
func charging()->void:
	if GlobalPlayerManager.player.hp < 1:
		queue_free()
	is_charging = true
	hurt_box.set_deferred("monitoring",false)
	animation_player.play("charging")
	play_audio(CHARGE)
	timer.start()
	await timer.timeout
	#await get_tree().create_timer(2.0).timeout
	animation_player.play("chasing")
	is_charging = false
	chasing()
	
func chasing()->void:
	play_audio(SHOOT)
	hurt_box.set_deferred("monitoring",true)
	target = GlobalPlayerManager.player.global_position
	move_direction = global_position.direction_to(target)
	animation_player.play("chasing")
	is_chasing = true
	timer.start()
	await timer.timeout
	#await get_tree().create_timer(2.0).timeout
	is_chasing = false
	queue_free()

func _on_touched_something()->void:
	is_chasing = false
	is_charging = false
	audio_stream_player_2d.stop()
	audio_stream_player_2d.stream = SHOCK
	audio_stream_player_2d.play()
	hurt_box.set_deferred("monitoring",false)
	visible = false
	pass
	
func play_audio(_audio:AudioStream)->void:
	audio_stream_player_2d.stream = _audio
	audio_stream_player_2d.play()
