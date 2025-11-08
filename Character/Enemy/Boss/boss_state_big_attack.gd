class_name BossStateBigAttack extends BossState

@export var anim_name : String = "idle"

@export_category("AI")
@export var state_duration_min: float = 0.5
@export var state_duration_max : float = 1.5
@export var next_state: BossState
const BEAM = preload("uid://c1mqi2fctyp5f")
const ORB = preload("uid://brk3000eta4nh")
@onready var cloak = %Cloak
var markers:Array[CastMarker]=[]
var marker_index:int=0
func init() -> void:
	pass

func _ready() -> void:
	assign_markers()
	pass
	
## What happens when the state is entered
func enter() -> void:
	print("boss big attack")
	boss.invulnerable=false
	boss.animation_player.play("big_attack")
	await boss.animation_player.animation_finished
	boss_state_machine.change_state(next_state)
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
	

func shoot() -> void:
	if markers.is_empty():
		return

	shoot_orb(marker_index)
	marker_index = wrapi(marker_index + 1, 0, markers.size())

	shoot_beam(marker_index)
	marker_index = wrapi(marker_index + 1, 0, markers.size())

	
func assign_markers()->void:
	for child in cloak.get_children():
		if child is CastMarker:
			markers.append(child)

func shoot_beam(_index:int)->void:
	var beam = BEAM.instantiate()
	get_tree().current_scene.add_child(beam)
	beam.global_position = markers[_index].global_position

func shoot_orb(_index:int)->void:
	var orb = ORB.instantiate()
	get_tree().current_scene.add_child(orb)
	orb.global_position = markers[_index].global_position
##
