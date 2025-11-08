class_name BossStateMachine extends Node


var states : Array[BossState]
var prev_state : BossState
var current_state : BossState


# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	change_state(current_state.process(delta))
	
func _physics_process(delta):
	change_state(current_state.physics(delta))


func initialize(_boss : Boss) -> void:
	states = []
	for child in get_children():
		if child is BossState:
			states.append(child)
	for state in states:
		state.boss = _boss
		state.boss_state_machine = self
		state.init()
	if states.size() > 0:
		change_state(states[0])
		process_mode = Node.PROCESS_MODE_INHERIT

func change_state(new_state : BossState) -> void:
	if new_state == current_state or new_state == null:
		return
	
	# Exits current state when changing states
	if current_state:
		current_state.exit()

	prev_state = current_state
	current_state = new_state
	current_state.enter()
