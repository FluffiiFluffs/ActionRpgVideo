@tool
@icon ("res://ASSETS/Icons/cutscene_camera.svg")
class_name CutsceneActionCamera
extends CutsceneAction

#signals inherited from extended script
#signal started
#signal finished

##Timing method constants
enum METHOD {DURATION, SPEED}

##THe method of timing
@export var timing_method : METHOD = METHOD.DURATION

##The transition type of the animation.[br] Default: TRANS_LINEAR
@export var transition_type : Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR
##Only works if transition_type is set to something besides TRANS_LINEAR
@export var easing_method: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
##How long the move should take
@export_range(0.0,10.0, 0.05, "s") var move_duration : float = 0.5
##How fast the move happens
@export_range(10.0,1000.0, 1.0, "px/s") var move_speed : float = 200.0
@export var reparent_to_player:bool=false

##Stores Camera2D node
var camera : Camera2D
##Stores the location of where the camera starts (should be the player)
var start_location : Vector2 = Vector2.ZERO
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
	camera = get_viewport().get_camera_2d() #assigns current active camera to var camera
	if camera: #if camera exists...
		if reparent_to_player == false:
			follow_the_node()
		else:
			follow_the_player()
	else: #If camera does not exist..
		printerr(str(name) + " DID NOT FIND CAMERA!!") #print this error!
		finished.emit() #emit finished anyways
	pass
	
	
func follow_the_node()->void:
		camera.process_mode = Node.PROCESS_MODE_ALWAYS #this NEEDS to be here, or the dialog manager will freeze the tween.
		start_location = camera.global_position #should be player position
		distance_to_target = start_location.distance_to(target_location) #Determines distance from target_location
		
		var follow_node : Node2D = Node2D.new() ##creates new node
		GlobalPlayerManager.player.add_sibling(follow_node) #adds new node to tree as sibling of player
		follow_node.global_position = start_location #puts the node location on the camera's current location
		camera.reparent(follow_node) #assigns camera to new parent
		
		if timing_method == METHOD.SPEED:
			move_duration = distance_to_target / move_speed
		elif timing_method == METHOD.DURATION:
			move_speed = distance_to_target / move_duration
			
		camera.position_smoothing_enabled = false #Camera moves weird after tween without this
		var tween : Tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.set_ease(easing_method)
		tween.set_trans(transition_type)
		tween.tween_property(follow_node, "global_position", target_location, move_duration)
		await get_tree().create_timer(move_duration*2, true).timeout
		camera.position_smoothing_enabled = true #makes sure the camera moves normally after
		_on_tween_finished()
		pass

func follow_the_player()->void:
		camera.process_mode = Node.PROCESS_MODE_ALWAYS #this NEEDS to be here, or the dialog manager will freeze the tween.
		start_location = camera.global_position #should be player position
		target_location = GlobalPlayerManager.player.global_position
		distance_to_target = start_location.distance_to(target_location) #Determines distance from target_location

		if timing_method == METHOD.SPEED:
			move_duration = distance_to_target / move_speed
		elif timing_method == METHOD.DURATION:
			move_speed = distance_to_target / move_duration
			
		camera.position_smoothing_enabled = false #Camera moves weird after tween without this
		var tween : Tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.set_ease(easing_method)
		tween.set_trans(transition_type)
		tween.tween_property(camera, "global_position", target_location, move_duration)
		camera.reparent(GlobalPlayerManager.player) #assigns camera to new parent
		await get_tree().process_frame
		camera.position_smoothing_enabled = true #makes sure the camera moves normally after
		_on_tween_finished()
		pass

##Camera process mode back to inherit, emits finished signal
func _on_tween_finished()->void:
	camera.process_mode = Node.PROCESS_MODE_INHERIT
	finished.emit()
	pass

func _draw()->void:
	if Engine.is_editor_hint():
		if !reparent_to_player:
			draw_circle( Vector2.ZERO, 3.0, Color.GREEN)
			draw_circle( Vector2.ZERO, 10.0, Color(0.0, 0.50, 1.0, 0.502), false, 1.0)
	pass
