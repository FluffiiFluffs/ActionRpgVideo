class_name NPCIdle
extends NPCState

@export var anim_name : String = "idle"

@export_category("AI")
@export var state_duration_min: float = 1.0
@export var state_duration_max : float = 2.0
@export var next_state: NPCState
@export var idle_duration : float = 2 ##default, but randomized later
@onready var patrol = %Patrol
@onready var wander = %Wander
@onready var npc_state_machine = %NPCStateMachine

var idle_done : bool = false


##What happens when state is initialized
func init() -> void:
	pass

func _ready() -> void:
	pass	
## What happens when the state is entered
func enter() -> void:

	if npc.player_detected == false:
		if npc.npc_will_patrol == true:
			idle_duration = patrol.idle_duration
			next_state = patrol
		elif npc.npc_will_patrol == false:
			if npc.npc_can_wander == true:
				idle_duration = 2.0
				next_state = wander
			elif npc.npc_will_patrol == false:
				idle_duration = 2.0
				next_state = self
	start()
## What happens when the state is exited
func exit() -> void:
	pass
	
	
## What happens during _process(): update while state is running
func process (_delta : float) -> NPCState:
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> NPCState:
	return null	
	
func start()-> void:
	if npc.player_detected == true:
		npc.update_direction(GlobalPlayerManager.player.global_position)
		idle_duration = 2.0
		#print("TORIEL " + str(npc.global_position))
		#print("Player " + str(GlobalPlayerManager.player.global_position))
		#npc.update_direction_name()
	npc.state = "idle"
	idle_duration = randf_range(state_duration_min,state_duration_max)
	#print(str(get_parent().get_parent().name) + " IDLE DURATION : " + str(idle_duration))
	npc.velocity = Vector2.ZERO
	npc.update_animation()
	#print("wait time: " , idle_duration)
	await get_tree().create_timer(idle_duration,false).timeout
	#print("idle_done")
	await get_tree().process_frame
	if next_state == self:
		start()
		#print("next_state = idle (self)")
		return
	if next_state != self:
		npc_state_machine.change_state(next_state)
		#print("next_state: " + str(next_state))	
