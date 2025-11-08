class_name NPCStateMachine extends Node


var states : Array[NPCState]
var prev_state : NPCState
var current_state : NPCState


# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	change_state(current_state.process(delta))
	
func _physics_process(delta):
	change_state(current_state.physics(delta))


func initialize(_npc : NPC) -> void:
	states = []
	for child in get_children():
		if child is NPCState:
			states.append(child)
	for state in states:
		state.npc = _npc
		state.state_machine = self
		state.init()
	if states.size() > 0:
		change_state(states[0])
		process_mode = Node.PROCESS_MODE_INHERIT

func change_state(new_state : NPCState) -> void:
	if new_state == current_state or new_state == null:
		return
	
	# Exits current state when changing states
	if current_state:
		current_state.exit()

	prev_state = current_state
	current_state = new_state
	current_state.enter()
