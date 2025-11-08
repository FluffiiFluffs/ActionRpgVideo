class_name PlayerStateStun extends PlayerState

@onready var walk :PlayerState= %Walk
@onready var idle :PlayerState= %Idle
@onready var attack :PlayerState= %Attack
@onready var death = %Death

@export var knockback_speed : float = 200.00
@export var decelerate_speed : float = 10.0
@export var invulnerable_duration : float = 1.5
@onready var effect_animation_player = %EffectAnimationPlayer
const LINK_HURT = preload("uid://dgr5q2ke32t6e")
@onready var audio_stream_player_2d = %AudioStreamPlayer2D
@onready var animation_player = %AnimationPlayer


var hurt_box : HurtBox
var direction : Vector2

var next_state : PlayerState = null



func init() -> void:
	player.player_damaged.connect(_on_player_damaged)

## What happens when the state is entered
func enter() -> void:
	drop_item()
	animation_player.stop()
	audio_stream_player_2d.stop()
	effect_animation_player.stop()
	player.hurt_box.monitoring = false #turns off hurtbox when player takes damage. Otherwise persists (bug)
	player.attack_sprite_2d.visible = false #turns off attack effect sprite when player takes damage. Otherwise persits(bug)
	audio_stream_player_2d.stream = LINK_HURT
	audio_stream_player_2d.pitch_scale = 1.3
	audio_stream_player_2d.play()
	if player.hp < 1:
		GameOverScreen.gameoverscreen_active=true
		state_machine.change_state(death)
		return
	
	player.animation_player.animation_finished.connect(_on_animation_finished)
	direction = player.global_position.direction_to(hurt_box.global_position)
	player.velocity = direction * -knockback_speed
	player.set_direction()
	player.update_animation("stun")


	player.make_invulnerable(invulnerable_duration)
	player.effect_animation_player.play("damaged")
	## What happens when the state is exited
func exit() -> void:
	effect_animation_player.play("RESET")
	next_state = null
	player.invulnerable = false
	if player.animation_player.animation_finished.is_connected(_on_animation_finished):
		player.animation_player.animation_finished.disconnect(_on_animation_finished)
	audio_stream_player_2d.pitch_scale = 1.0
	
	
func drop_item()->void:
	#if prop present on player, then release it in the direction the player is facing with no hurtbox
	if GlobalPlayerManager.player.held_prop != null:
		GlobalPlayerManager.player.held_prop_throwable.throw()
	#set player.held_prop to nul
	pass
	
	
## What happens during _process(): update while state is running
func process (_delta : float) -> PlayerState:
	player.velocity -= player.velocity * decelerate_speed * _delta
	return next_state

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> PlayerState:
	return null	
	
## What happens with input events while this state is running
func handle_input( _event: InputEvent) -> PlayerState:
	return null

func _on_player_damaged(_hurt_box : HurtBox) -> void:
	hurt_box = _hurt_box
	if state_machine.current_state != death:
		state_machine.change_state(self)

func _on_animation_finished(_a : String) -> void:
	next_state = idle
