class_name BossStateAttack1 extends BossState

@export var anim_name : String = "idle"

@export_category("AI")
@export var state_duration_min: float = 0.5
@export var state_duration_max : float = 1.5
@export var next_state: BossState
const ORB = preload("uid://brk3000eta4nh")
@onready var teleport = %Teleport



func init() -> void:
	pass

func _ready() -> void:
	pass
	
## What happens when the state is entered
func enter() -> void:
	print("boss attack1")
	boss.animation_player.play("cast01")
	boss.invulnerable=false
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

func shoot_orb1()->void:
	var orb = ORB.instantiate()
	get_tree().current_scene.add_child(orb)
	orb.global_position = boss.cast_marker_left.global_position
	
func shoot_orb2()->void:
	var orb = ORB.instantiate()
	get_tree().current_scene.add_child(orb)
	orb.global_position = boss.cast_marker_right.global_position
		
