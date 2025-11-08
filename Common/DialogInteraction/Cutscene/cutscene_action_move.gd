@tool
@icon ("res://ASSETS/Icons/cutscene_actor.svg")
class_name CutsceneActionMove
extends CutsceneAction

#signals inherited from extended script
#signal started
#signal finished

enum METHOD {DURATION, SPEED}

##THe method of timing
@export var timing_method : METHOD = METHOD.DURATION
##What object should be moved
@export var object_to_move : Node2D
##The transition type of the animation.[br] Default: TRANS_LINEAR
@export var transition_type : Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR
##Only works if transition_type is set to something besides TRANS_LINEAR
@export var easing_method: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
##How long the move should take
@export_range(0.0,10.0, 0.05, "s") var move_duration : float = 0.5
##How fast the move happens
@export_range(10.0,1000.0, 1.0, "px/s") var move_speed : float = 200.0
##How fast the animation plays
@export var animation_speed_factor : float = 40.0

##Where the move goes to (Vector2)
var target_location: Vector2 = Vector2.ZERO
##What direction to move
var move_direction : Vector2 = Vector2.ZERO
##How far from the target
var distance_to_target : float = 0.0

func _ready()->void:
	target_location = global_position
	#_draw()
	pass

##Inherited from CutsceneAction
func play()->void:
	if object_to_move:
		object_to_move.process_mode = Node.PROCESS_MODE_ALWAYS #Ensures object can be moved during dialog pause
		distance_to_target = calculate_distance_to_target()
		get_move_direction()
		if timing_method == METHOD.SPEED:
			move_duration = distance_to_target / move_speed
		elif timing_method == METHOD.DURATION:
			move_speed = distance_to_target / move_duration
			
		if object_to_move is NPC:
			var npc : NPC = object_to_move
			npc.update_direction(target_location)
			npc.animation_player.play("walk_" + str(npc.direction_name))
			npc.animation_player.speed_scale = move_speed / animation_speed_factor

		var tween : Tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) #ensures tween can run. IMPORTANT!
		tween.set_ease(easing_method)
		tween.set_trans(transition_type)
		tween.tween_property(object_to_move, "global_position", target_location, move_duration)
		tween.tween_callback(_on_tween_finished)
		pass
	else:
		finished.emit() #signal exists in parent class
	pass
	
func _on_tween_finished()->void:
	object_to_move.process_mode = Node.PROCESS_MODE_INHERIT

	if object_to_move is NPC:
		var npc : NPC = object_to_move
		npc.npc_state_machine.change_state(npc.idle)
		npc.animation_player.speed_scale = 1
		npc.process_mode = Node.PROCESS_MODE_INHERIT
	
	finished.emit()
	pass

func get_move_direction()->void:
	if object_to_move:
		move_direction = object_to_move.global_position.direction_to(target_location)

func calculate_distance_to_target()->float:
	return object_to_move.global_position.distance_to(target_location)

func _draw()->void:
	if Engine.is_editor_hint():
		draw_circle( Vector2.ZERO, 3.0, Color.RED)
		draw_circle( Vector2.ZERO, 10.0, Color(1.0, 0, 0, 0.5), false, 1.0)
	pass
