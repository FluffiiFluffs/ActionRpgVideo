class_name BossStateStun extends BossState



@onready var audio_stream_player_2d = %AudioStreamPlayer2D
const HIT = preload("uid://cio7lkrhdchfq")


@export var anim_name : String = "idle"

@export_category("AI")
@export var state_duration_min: float = 0.5
@export var state_duration_max : float = 1.5
@export var next_state: BossState

var _timer : float = 0.0

func init() -> void:
	pass

func _ready() -> void:
	await get_tree().process_frame
	boss.boss_damaged.connect(enter)
	pass
	
## What happens when the state is entered
func enter() -> void:
	destroy_charging_energy()
	audio_stream_player_2d.stream = HIT
	audio_stream_player_2d.play()
	print("BOSS HIT!" + " " + "HP: " + str(boss.hp))
	boss.invulnerable=true
	boss.animation_player.play("stun")
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
	
	
func destroy_charging_energy()->void:
	for child in get_tree().current_scene.get_children():
		if child is EnergyBeamSmall or child is EnergyOrb:
			if child.is_charging:
				child.queue_free()
