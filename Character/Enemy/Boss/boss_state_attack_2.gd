class_name BossStateAttack2 extends BossState

@export var anim_name : String = "idle"

@export_category("AI")
@export var state_duration_min: float = 0.5
@export var state_duration_max : float = 1.5
@export var next_state: BossState
const BEAM = preload("uid://c1mqi2fctyp5f")

func init() -> void:
	pass

func _ready() -> void:
	pass
	
## What happens when the state is entered
func enter() -> void:
	print("boss attack2")
	boss.invulnerable=false
	boss.animation_player.play("cast02")
	await boss.animation_player.animation_finished
	boss_state_machine.change_state(next_state)
	pass
## What happens when the state is exited
func exit() -> void:
	boss.animation_player.stop()

	pass
	
	
## What happens during _process(): update while state is running
func process (_delta : float) -> BossState:

	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> BossState:
	return null	

func shoot_beam1()->void:
	var beam = BEAM.instantiate()
	get_tree().current_scene.add_child(beam)
	beam.global_position = boss.cast_marker_left.global_position
	
func shoot_beam2()->void:
	var beam = BEAM.instantiate()
	get_tree().current_scene.add_child(beam)
	beam.global_position = boss.cast_marker_right.global_position
		
