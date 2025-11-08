class_name NPCWander
extends NPCState

@export var anim_name : String = "walk"
@onready var idle = %Idle
@onready var npc_state_machine = %NPCStateMachine
@onready var p_det_area_2d = %PDetArea2D


@export_category("AI")
@export var next_state: NPCState
@export var wander_range : float = 2
@export var wander_speed : float = 30.0
@export var wander_cycle_min : float = 1.0
@export var wander_cycle_max : float = 2.5
var wander_duration : float = randf_range(wander_cycle_min,wander_cycle_max)

var original_position : Vector2
var wander_done = false

##What happens when state is initialized
func init() -> void:
	pass

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	original_position = npc.global_position

## What happens when the state is entered
func enter() -> void:
	wander_done = false
	start()

## What happens when the state is exited
func exit() -> void:
	pass
	
## What happens during _process(): update while state is running
func process (_delta : float) -> NPCState:
	if Engine.is_editor_hint():
		return
	if wander_done == true:
		return next_state
	if npc.player_detected == true:
		npc_state_machine.change_state(idle)

	#return null
	#if npc.player_detected:
		#npc.velocity = Vector2.ZERO
		#npc.animation_player.play("idle_" + npc.direction_name)
	return null
## What happens during _physics_process(): update state is running
func physics( _delta: float) -> NPCState:
	return null	

func start() -> void:
	if npc.player_detected == true:
		wander_done = true
	elif npc.player_detected == false:
		npc.state = "walk"
		wander_duration = randf_range(wander_cycle_min,wander_cycle_max)
		var _dir : Vector2 = npc.DIR_4[ randi_range(0,3) ]
		#points NPC back towards the original position if outside wander range
		if abs( npc.global_position.distance_to( original_position ) ) > wander_range * 32:
			#print("OUTSIDE AREA")
			var dir_to_area : Vector2 = npc.global_position.direction_to( original_position )
			var best_directions : Array[ float ] = []
			for d in npc.DIR_4:
				best_directions.append( d.dot( dir_to_area ) )
			_dir = npc.DIR_4[ best_directions.find( best_directions.max() ) ]
		#print ("NPC RANGE FROM ORIGINAL : " + str(abs( npc.global_position.distance_to( original_position ) )))
		npc.direction = _dir
		npc.velocity = wander_speed * _dir
		npc.update_direction( npc.global_position + _dir )
		npc.update_animation()
		await get_tree().create_timer( wander_duration,false ).timeout
		wander_done = true
