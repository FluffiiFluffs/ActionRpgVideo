class_name BossState extends Node

## Stores a reference to the enemy that this state belongs to
var boss : Boss
var boss_state_machine : BossStateMachine

##What happens when state is initialized
func init() -> void:
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
func process (_delta : float) -> BossState:
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> BossState:
	return null	
