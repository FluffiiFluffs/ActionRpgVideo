class_name PlayerStateIdle extends PlayerState

@onready var walk :PlayerState= %Walk
@onready var idle :PlayerState= %Idle
@onready var attack :PlayerState= %Attack
@onready var ability = %Ability
@onready var hurt_box = %HurtBox

## What happens when the state is entered
func enter() -> void:
	player.update_animation("idle")
	GlobalPlayerManager.is_moving = false
	pass
## What happens when the state is exited
func exit() -> void:
	pass
	
	
## What happens during _process(): update while state is running
func process (_delta : float) -> PlayerState:
	if player.direction != Vector2.ZERO:
		return walk
	player.velocity = Vector2.ZERO
	player.sprite.scale.x = -1 if player.cardinal_direction == Vector2.LEFT else 1
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> PlayerState:
	return null	
	
## What happens with input events while this state is running
func handle_input( _event: InputEvent) -> PlayerState:
	if (PauseMenu.menu_is_open or 
		InventoryMenu.inventory_is_open or 
		PauseMenu.menu_is_animating or 
		InventoryMenu.inventory_is_animating or
		GlobalLevelManager.title_screen_active == true or
		DialogSystem.cutscene_in_progress == true):
			return
	if _event.is_action_pressed("confirm_input"):
		return attack
	if _event.is_action_pressed("interact_input"):
		GlobalPlayerManager.interact_pressed.emit()
	if _event.is_action_pressed("special_input"):
		return ability
	return null
	

func init():
	pass
