class_name BossStateDeath extends BossState
@onready var audio_stream_player_2d = %AudioStreamPlayer2D

@export var anim_name : String = "idle"

@export_category("AI")
@export var state_duration_min: float = 1.0
@export var state_duration_max : float = 2.5
const BOSS_DIES = preload("uid://quiuao80n3wp")


var _timer : float = 0.0


func init() -> void:
	pass

func _ready() -> void:

	pass
	
## What happens when the state is entered
func enter() -> void:
	destroy_charging_energy()
	boss.timer_1.stop()
	boss.timer_1.queue_free()
	boss.hit_box.queue_free()
	boss.collision_shape_2d.queue_free()
	audio_stream_player_2d.stream = BOSS_DIES
	audio_stream_player_2d.play()
	boss.animation_player.play("death")
	await boss.animation_player.animation_finished
	boss.boss_is_gone.emit()
	boss.queue_free()
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

func _death_state_change()->void:
	boss_state_machine.change_state(self)
	
func destroy_charging_energy()->void:
	for child in get_tree().current_scene.get_children():
		if child is EnergyBeamSmall or child is EnergyOrb:
				child.queue_free()
		if child is Torch:
			for c in child.get_children():
				if c is EnergyBeamSmall or c is EnergyOrb:
						c.queue_free()
