class_name PlayerStateCarry
extends PlayerState


@export var move_speed:float= 95.0
@export var throw_sfx:AudioStream
@onready var stun :PlayerStateStun= %Stun
@onready var idle :PlayerStateIdle= %Idle

var walking:bool=false
var throwable:Throwable
var prop=null
func init() -> void:
	pass


func _ready() -> void:
	pass
	
## What happens when the state is entered
func enter() -> void:
	player.update_animation("carry")
	walking = false
	
	#player.held_prop = prop

	
	
## What happens when the state is exited
func exit() -> void:
	#if throwable:
		if state_machine.next_state == stun:
			drop_item()
			pass
		elif state_machine.next_state == idle:
			#throw the pot in the direction the player is facing
				#handled by prop
			if GlobalPlayerManager.player.held_prop != null:
				GlobalPlayerManager.player.held_prop_throwable.throw()
				
				
func drop_item()->void:
	#if prop present on player, then release it in the direction the player is facing with no hurtbox
	if GlobalPlayerManager.player.held_prop != null:
		GlobalPlayerManager.player.held_prop_throwable.throw()
	#set player.held_prop to nul
	pass
				
			
## What happens during _process(): update while state is running
func process (_delta : float) -> PlayerState:
	if player.direction == Vector2.ZERO:
		walking = false
		player.update_animation("carry")
	elif player.set_direction() or walking == false:
		player.update_animation("carry_walk")
		walking = true
	player.sprite.scale.x = -1 if player.cardinal_direction == Vector2.LEFT else 1
	player.velocity = player.direction * move_speed
	return

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> PlayerState:
	return null	
	
## What happens with input events while this state is running
func handle_input( _event: InputEvent) -> PlayerState:
	if Input.is_action_just_pressed("interact_input"):
		#throw prop, controlled by prop
		#print("returnidle?")
		return idle
	return null
