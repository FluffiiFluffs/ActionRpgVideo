class_name BossStateTeleport extends BossState

@export var anim_name : String = "idle"

@export_category("AI")
@export var state_duration_min: float = 0.5
@export var state_duration_max : float = 1.5
@export var next_state: BossState
@onready var idle = %Idle

var last_loc:int=0
var _random_loc:int=0

var _timer : float = 0.0

func init() -> void:
	pass

func _ready() -> void:
	pass
	
## What happens when the state is entered
func enter() -> void:
	boss.animation_player.stop()
	print("boss teleporting")
	random_loc()
	teleport(_random_loc)

	
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
	
func teleport(_loc:int)->void:
	boss.invulnerable=true
	_loc = _random_loc
	var tween := create_tween()
	var tele_loc =  boss.teleport_markers[_loc].global_position
	boss.modulate.a = 0.05
	tween.tween_property(boss, "global_position",tele_loc, 0.3)
	await tween.finished
	fade_tween()
	boss.invulnerable=false
	boss_state_machine.change_state(idle)

func fade_tween()->void:
	var tween := create_tween()
	tween.chain().tween_property(boss,"modulate:a", 1.0, 0.45)

func random_loc()->void:
	var loc_range = randi_range(0, (boss.teleport_markers.size()-1))
	if last_loc == loc_range:
		enter()
	else:
		_random_loc=loc_range
		last_loc=loc_range
		
