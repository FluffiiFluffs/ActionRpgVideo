class_name EnemyStateChase extends EnemyState

@export var anim_name : String = "chase"
@export var chase_speed : float = 45.0
@export var turn_rate : float = 0.25

@export_category("AI")
#ALERT ASSIGN THIS IN INSPECTOR
@export var vision_area: VisionArea
#ALERT ASSIGN THIS IN INSPECTOR
@export var attack_area: HurtBox
##How long after losing the player the enemy will continue chasing.
@export var state_aggro_duration: float = 2.5
#ALERT ASSIGN THIS IN INSEPCTOR
@export var next_state: EnemyState

var _timer : float = clampf(state_aggro_duration, 0, 5.0)
var _direction : Vector2
var _player_is_seen:bool= false


##What happens when state is initialized
func init() -> void:
	if vision_area:
		vision_area.player_entered.connect(_on_player_entered)
		vision_area.player_exited.connect(_on_player_exited)
	

func _ready() -> void:
	pass
	
## What happens when the state is entered
func enter() -> void:
	_timer = state_aggro_duration
	enemy.update_animation(anim_name)
	if attack_area:
		attack_area.monitoring = true

	pass
## What happens when the state is exited
func exit() -> void:
	if attack_area:
		attack_area.monitoring = false
	_player_is_seen = false	
	
	
## What happens during _process(): update while state is running
func process (_delta : float) -> EnemyState:
	var new_dir : Vector2 = enemy.global_position.direction_to(GlobalPlayerManager.player.global_position)
	_direction = lerp(_direction, new_dir, turn_rate)
	enemy.velocity = _direction * chase_speed
	if enemy.set_direction(_direction):
		enemy.update_animation(anim_name)
	if !_player_is_seen:
		_timer -= _delta
		if _timer < 0:
			#print("CHASE TIMER ZERO")
			return next_state
	else:
		_timer = state_aggro_duration
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> EnemyState:
	return null	


func _on_player_entered():
	_player_is_seen = true
	if(
			state_machine.current_state is EnemyStateAbilityStun
			or state_machine.current_state is EnemyStateDestroyed
			or enemy.is_ability_stunned == true
	):
		_player_is_seen = false
		return
	#if state_machine.current_state == EnemyStateStun:
	#print("PLAYER ENTERED")
	state_machine.change_state(self)

func _on_player_exited():
	#print("PLAYER EXITED")
	_player_is_seen = false
