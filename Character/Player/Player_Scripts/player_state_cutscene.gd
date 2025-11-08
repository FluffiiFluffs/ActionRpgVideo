class_name PlayerStateCutscene extends PlayerState

@onready var walk :PlayerState= %Walk
@onready var idle :PlayerState= %Idle
@onready var attack :PlayerState= %Attack
@onready var ability = %Ability
@onready var hurt_box = %HurtBox

## What happens when the state is entered
func enter() -> void:
	player.update_animation("idle")
	GlobalPlayerManager.is_moving = false
	player.process_mode = Node.PROCESS_MODE_ALWAYS #unpauses player during cutscene
	pass
## What happens when the state is exited
func exit() -> void:
	player.process_mode = Node.PROCESS_MODE_INHERIT #puts player back to normal
	pass
	
	
## What happens during _process(): update while state is running
func process (_delta : float) -> PlayerState:
	#if player.direction != Vector2.ZERO:
		#return walk
	player.velocity = Vector2.ZERO
	#player.sprite.scale.x = -1 if player.cardinal_direction == Vector2.LEFT else 1
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> PlayerState:
	return null	
	
## What happens with input events while this state is running
func handle_input( _event: InputEvent) -> PlayerState:
	return null

func init():
	DialogSystem.started.connect(_on_dialog_started)
	DialogSystem.finished.connect(_on_dialog_finished)

func _on_dialog_finished()->void:
	state_machine.change_state(idle)
	pass

func _on_dialog_started()->void:
	state_machine.change_state(self)
	pass
