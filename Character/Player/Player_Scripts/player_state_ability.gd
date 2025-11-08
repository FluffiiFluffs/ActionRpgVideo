class_name PlayerStateAbility extends PlayerState

@onready var walk :PlayerState= %Walk
@onready var idle :PlayerState= %Idle
@onready var attack :PlayerState= %Attack
@onready var audio_stream_player_2d = %AudioStreamPlayer2D

@export_range(1.0, 20.0, 0.5) var decelerate_speed : float = 5.0
const BOOMERANG = preload("uid://d4gfgba08qkhb")
var boomerang_instance = null

var using_ability: bool = false

func init():
	pass

## What happens when the state is entered
func enter() -> void:
	var _current_ability = GlobalPlayerManager.current_ability
	do_ability(_current_ability)

	
	
## What happens when the state is exited
func exit() -> void:
	pass
## What happens during _process(): update while state is running
func process (delta : float) -> PlayerState:
	player.velocity -= player.velocity * decelerate_speed * delta
	if using_ability == false:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> PlayerState:
	return null	
	
## What happens with input events while this state is running
func handle_input( _event: InputEvent) -> PlayerState:
	return null


func do_ability(ability):
	match ability:
		GlobalPlayerManager.AbilityState.BOOMERANG:
			player.velocity = Vector2.ZERO
			using_ability = true
			boomerang_ability()
			#print("BOOMERANG")
			await get_tree().create_timer(0.2).timeout
			using_ability = false
		GlobalPlayerManager.AbilityState.BOW:
			pass
		GlobalPlayerManager.AbilityState.BOMB:
			pass
		GlobalPlayerManager.AbilityState.HOOKSHOT:
			pass
		GlobalPlayerManager.AbilityState.NONE:
			pass
		_:
			pass


func boomerang_ability() -> void:
	if boomerang_instance != null:
		return
	
	var _boomerang = BOOMERANG.instantiate() as Boomerang
	player.add_sibling( _boomerang )
	_boomerang.global_position = player.global_position + Vector2(0, -10)
	
	var throw_direction = player.direction
	if throw_direction == Vector2.ZERO:
		throw_direction = player.cardinal_direction
	
	_boomerang.throw( throw_direction )
	boomerang_instance = _boomerang
	pass
