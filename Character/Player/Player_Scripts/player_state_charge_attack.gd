class_name PlayerStateChargeAttack
extends PlayerState

const SPARKLEANIM:PackedScene = preload("uid://dn1dusllgk06h")
const CHARGED_FLAME:PackedScene = preload("uid://4xrbunb2w7gm")
const CHARGED_SPARK:PackedScene = preload("uid://ckwyk4nf3ssvj")
const SPIN_EFFECT_BLUE:PackedScene = preload("uid://ywvv6nytpgwu")
const SPIN_EFFECT_YELLOW:PackedScene = preload("uid://dra7trpkwy8om")

@onready var idle = %Idle

@export var charge_duration: float = 0.9
@export var move_speed : float = 70.0
@export var sfx_charged : AudioStream
@export var sfx_spin : AudioStream
@onready var charge_up_hurt_box = %ChargeUpHurtBox
@onready var charge_hurt_box = %ChargeHurtBox
@onready var audio_stream_player_2d = %AudioStreamPlayer2D
@onready var sparkle_marker_2d = %SparkleMarker2D
@onready var effect_animation_player = %EffectAnimationPlayer
@onready var spin_marker_2d = %SpinMarker2D

var timer:float = 0.0
var walking : bool = false
var is_charged:bool= false
var is_attacking:bool=false
var first_direction:String
var first_cardinal_direction:Vector2


func init() -> void:
	pass

func _ready() -> void:
	charge_up_hurt_box.hurt_something.connect(on_hurt_something)
	
## What happens when the state is entered
func enter() -> void:
	first_direction = player.AnimDirection()
	first_cardinal_direction = player.cardinal_direction
	timer = charge_duration
	is_attacking = false
	walking = false
	is_charged = false
	charge_up_hurt_box.monitoring = true
	effect_animation_player.play("charge_sparkle_" + first_direction)
## What happens when the state is exited
func exit() -> void:
	player.direction = first_cardinal_direction
	player.cardinal_direction = first_cardinal_direction
	charge_up_hurt_box.monitoring = false
	charge_hurt_box.monitoring = false
	is_charged = false
	effect_animation_player.stop()
	
	
## What happens during _process(): update while state is running
func process (_delta : float) -> PlayerState:
	if timer > 0:
		timer -= _delta
		if timer <= 0:
			timer = 0
			is_charged = true
	
	if is_attacking == false:
		if player.direction == Vector2.ZERO:
			walking = false
			player.animation_player.play("charge_" + first_direction)
		elif player.set_direction() or walking == false:
			player.animation_player.play("charge_walk_" + first_direction)
		if first_direction == "right" and first_cardinal_direction == Vector2.RIGHT:
			player.sprite.scale.x = 1
		elif first_direction == "right" and first_cardinal_direction == Vector2.LEFT:
			player.sprite.scale.x = -1
			#player.sprite.scale.x = -1 if player.cardinal_direction == Vector2.LEFT else 1
		player.velocity = player.direction * move_speed
	elif is_attacking == true:
		player.velocity = Vector2.ZERO
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> PlayerState:
	return null	
	
## What happens with input events while this state is running
func handle_input( _event: InputEvent) -> PlayerState:
	if Input.is_action_just_released("confirm_input"):
		if timer > 0:
			return idle
		elif is_attacking == false:
			charge_attack()
	return null

func charge_attack()->void:
	effect_animation_player.stop()
	is_charged = false
	is_attacking = true
	audio_stream_player_2d.stream = sfx_spin
	audio_stream_player_2d.play()
	charge_up_hurt_box.monitoring = false
	charge_hurt_box.monitoring = true
	player.animation_player.play("charge_attack")
	player.animation_player.seek(get_spin_frame())
	var _duration:float=player.animation_player.current_animation_length
	player.make_invulnerable(_duration)
	await get_tree().create_timer(_duration).timeout
	state_machine.change_state(idle)


func get_spin_frame()->float:
	var interval:float=0.05   #distance between frames
	match first_cardinal_direction:
		Vector2.DOWN:
			return interval*0
		Vector2.UP:
			return interval*4
		Vector2.LEFT:
			return interval*6
		Vector2.RIGHT:
			return interval*6
		_:
			return interval*0
			
			
func on_hurt_something(hit_box):
	if hit_box.get_parent() is Plant:
		return
	elif hit_box.get_parent() is Enemy:
		#await get_tree().create_timer(0.01).timeout
		await get_tree().process_frame
		state_machine.change_state(idle)

func play_charged_animmation()->void:
	effect_animation_player.play("charged_sparkle_" + first_direction)
	audio_stream_player_2d.stream = sfx_charged
	audio_stream_player_2d.play()

func make_sparkle() -> void:
	var _sparkle = SPARKLEANIM.instantiate()
	get_tree().current_scene.add_child(_sparkle)
	_sparkle.global_transform = sparkle_marker_2d.global_transform

	
func make_charged_flame()->void:
	var _flame = CHARGED_FLAME.instantiate()
	get_tree().current_scene.add_child(_flame)
	_flame.global_transform = sparkle_marker_2d.global_transform
	
func make_charged_spark()->void:
	var _spark = CHARGED_SPARK.instantiate()
	get_tree().current_scene.add_child(_spark)
	_spark.global_transform = sparkle_marker_2d.global_transform
	
func make_yellow_spin_effect()->void:
	var _yellow_spin_effect = SPIN_EFFECT_YELLOW.instantiate()
	get_tree().current_scene.add_child(_yellow_spin_effect)
	_yellow_spin_effect.global_position = spin_marker_2d.global_position

func make_blue_spin_effect()->void:
	var _blue_spin_effect = SPIN_EFFECT_BLUE.instantiate()
	get_tree().current_scene.add_child(_blue_spin_effect)
	_blue_spin_effect.global_position = spin_marker_2d.global_position
