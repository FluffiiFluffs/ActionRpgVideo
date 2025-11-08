class_name BossStateAvoid extends BossState

@export var anim_name : String = "idle"

@export_category("AI")
@export var state_duration_min: float = 0.5
@export var state_duration_max : float = 1.5
@export var next_state: EnemyState

var _timer : float = 0.0

func init() -> void:
	pass

func _ready() -> void:
	pass
	
## What happens when the state is entered
func enter() -> void:
	pass
## What happens when the state is exited
func exit() -> void:
	pass
	
	
## What happens during _process(): update while state is running
func process (_delta : float) -> BossState:
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> BossState:
	return null	
