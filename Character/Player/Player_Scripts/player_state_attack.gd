class_name PlayerStateAttack extends PlayerState

@onready var walk :PlayerState= %Walk
@onready var idle :PlayerState= %Idle
@onready var attack :PlayerState= %Attack
@onready var animation_player :AnimationPlayer= %AnimationPlayer
@onready var attack_sprite_2d = %AttackSprite2D
@onready var audio_stream_player_2d = %AudioStreamPlayer2D
@onready var hurt_box = %HurtBox
@onready var charge_attack = %ChargeAttack

@export_range(1.0, 20.0, 0.5) var decelerate_speed : float = 5.0
@export var attack_sound : AudioStream

var attacking: bool = false

func init():
	pass

## What happens when the state is entered
func enter() -> void:
	
	attacking = true
	player.update_animation("attack")
	animation_player.animation_finished.connect(end_attack)
	audio_stream_player_2d.stream = attack_sound
	audio_stream_player_2d.play()
	await get_tree().create_timer(0.06).timeout
	if attacking: #ensures player hurtbox does not persist when hit
		hurt_box.monitoring = true
	
	
## What happens when the state is exited
func exit() -> void:
	animation_player.animation_finished.disconnect(end_attack)
	attacking = false
	hurt_box.monitoring = false
	pass

## What happens during _process(): update while state is running
func process (delta : float) -> PlayerState:
	player.velocity -= player.velocity * decelerate_speed * delta
	if attacking == false:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
	if player.direction == Vector2.UP or player.direction == Vector2.LEFT:
		attack_sprite_2d.show_behind_parent = true
	else:
		attack_sprite_2d.show_behind_parent = false
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> PlayerState:
	return null	
	
## What happens with input events while this state is running
func handle_input( _event: InputEvent) -> PlayerState:

		
	return null

func end_attack(_newAnimName: String)-> void:
	if Input.is_action_pressed("confirm_input"):
		state_machine.change_state(charge_attack)
	attacking = false
