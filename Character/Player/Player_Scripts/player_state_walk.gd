class_name PlayerStateWalk extends PlayerState

@export var move_speed : float = 115.00
@onready var walk :PlayerState= %Walk
@onready var idle :PlayerState= %Idle
@onready var attack :PlayerState= %Attack
@onready var hurt_box = %HurtBox
@onready var ability = %Ability

func init():
	pass

## What happens when the state is entered
func enter() -> void:
	player.update_animation("walk")
	GlobalPlayerManager.is_moving = true
	pass
## What happens when the state is exited
func exit() -> void:
	pass
	
	
## What happens during _process(): update while state is running
func process (_delta : float) -> PlayerState:
	if player.direction == Vector2.ZERO:
		return idle
		
	player.velocity = player.direction * move_speed
	if player.set_direction():
		player.update_animation("walk")
	player.sprite.scale.x = -1 if player.cardinal_direction == Vector2.LEFT else 1
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> PlayerState:
	return null	
	
## What happens with input events while this state is running
func handle_input( _event: InputEvent) -> PlayerState:
	if _event.is_action_pressed("confirm_input"):
		return attack
	if _event.is_action_pressed("interact_input"):
		GlobalPlayerManager.interact_pressed.emit()
	if _event.is_action_pressed("special_input"):
		return ability
	return null
