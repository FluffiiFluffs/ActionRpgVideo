class_name PlayerState extends Node

##Stores reference to the player that this PlayerState belongs to
static var player: Player
static var state_machine: PlayerStateMachine

func _init() -> void:
	pass

func _ready() -> void:
	pass
	
## What happens when the state is entered
func enter() -> void:
	pass
## What happens when the state is exited
func exit() -> void:
	pass
	
	
## What happens during _process(): update while state is running
func process (_delta : float) -> PlayerState:
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> PlayerState:
	return null	
	
## What happens with input events while this state is running
func handle_input( _event: InputEvent) -> PlayerState:
	return null
