#class_name NPCPushed
#
extends NPCState


@onready var push_area_2d = %PushArea2D

@export var next_state: NPCState
@export var push_speed : float = 30.0
var pushed_done :bool= false
var player_pushing : bool = false
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
func process (_delta : float) -> NPCState:
	if pushed_done == true:
		return next_state
	if GlobalPlayerManager.is_moving and npc.player_detected:
		print("PUSHED")
		npc.velocity = GlobalPlayerManager.player.cardinal_direction * push_speed
	elif !GlobalPlayerManager.is_moving and !npc.player_detected:
		return next_state
	return null
## What happens during _physics_process(): update state is running
func physics( _delta: float) -> NPCState:
	return null	


	
func pushed_timer():
	var timer = Timer.new()
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = 2.0
	add_child(timer)
	timer.timeout.connect(func check():
			pushed_done = false
			timer.queue_free())
			
func pushed_area_timer():
	var timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 0.15
	add_child(timer)
	timer.timeout.connect(func check():
		if push_area_2d.overlaps_body(GlobalPlayerManager.player):
			if GlobalPlayerManager.player.is_moving:
				player_pushing = true
			elif !GlobalPlayerManager.player.is_moving:
				player_pushing = false
		elif !push_area_2d.overlaps_body(GlobalPlayerManager.player) :
			#print("PLAYER NOT OVERLAPPING")
			player_pushing = false
		timer.queue_free())
	
