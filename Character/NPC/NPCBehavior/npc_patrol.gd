class_name NPCPatrol
extends NPCState

@onready var idle = %Idle
@onready var npc_state_machine = %NPCStateMachine

@export var walk_speed: float = 30.0

var patrol_locations: Array[PatrolLocation]
var current_location_index: int = 0
var target: PatrolLocation
var direction: Vector2
var idle_duration : float

func _ready() -> void:
	await get_tree().process_frame
	gather_patrol_locations()
	if patrol_locations.size() == 0:
		return
	target = patrol_locations[0]
func init() -> void:
	pass

func enter() -> void:

	if patrol_locations.size() < 2:
		printerr("NPC" + str(npc.name) + " DOES NOT HAVE ANY PATROL LOCATIONS AS CHILDREN!")
		printerr("NPC " + str(npc.name) + " SET TO WANDER MODE")
		npc.npc_will_patrol = false
		npc.npc_can_wander = true
		npc_state_machine.change_state(idle)
	if target:
		if target.target_position.distance_to(npc.global_position) < 1:
			current_location_index = (current_location_index + 1) % patrol_locations.size()
			target = patrol_locations[current_location_index]
		walk_phase()  # begin by walking toward the first target


func exit() -> void:
	if target == null:
		idle_duration = 1.0
	elif target != null:
		idle_duration = target.wait_time
	# velocity cleanup so you do not carry motion into the next state
	npc.velocity = Vector2.ZERO

func process(_delta: float) -> NPCState:
	if !patrol_locations.is_empty():
		
		# if a player interrupt is active, stop here
		if npc.player_detected:
			return idle

		# continuous steering straight to the current target
		var to_target: Vector2 = target.target_position - npc.global_position
		var dist: float = to_target.length()

		# arrive exactly at the corner if we would pass it this frame
		var step: float = walk_speed * _delta
		if dist <= step:
			return idle

		# otherwise keep moving straight toward the target
		direction = to_target / dist
		npc.direction = direction
		npc.velocity = walk_speed * direction
		npc.update_direction(target.target_position)
		npc.animation_player.play("walk_" + str(npc.direction_name))
	return null

func physics(_delta: float) -> NPCState:
	return null

func gather_patrol_locations(_n: Node = null) -> void:
	patrol_locations = []
	for c in npc.get_children():
		if c is PatrolLocation:
			patrol_locations.append(c)


func walk_phase() -> void:
	npc.direction = npc.global_position.direction_to(target.target_position)
	npc.velocity = walk_speed * npc.direction
	npc.update_direction(target.target_position)
