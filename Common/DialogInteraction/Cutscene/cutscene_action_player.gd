@tool
@icon ("uid://dwo3npik7p1ir")
class_name CutsceneActionPlayer
extends CutsceneAction

#signals inherited from extended script
#signal started
#signal finished

enum METHOD {DURATION, SPEED}

##The name of the animation the player will perform
@export var animation_name : String = "walk"
##force the finished direction instead of using the direction of player movement
@export_enum("up","down","left","right") var forced_finish_direction = ""
##If the camera is reset to the player when cutscene action finishes
@export var reset_camera_to_player:bool=false
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
##If the animation scales with the movement speed
@export var scale_animation_with_movement:bool=true
##How fast the animation plays
@export var animation_speed_factor : float = 200.0


##Which direction to face when the animation finishes
var finish_direction : String = "up"
##Where the player starts
var start_location:Vector2=Vector2.ZERO
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
	var player : Player = GlobalPlayerManager.player
	start_location = player.global_position
	distance_to_target = start_location.distance_to(target_location)
	move_direction = start_location.direction_to(target_location)
	update_direction_name()
	player.direction = move_direction
	player.set_direction()
	#player.update_animation(animation_name)
	player.animation_player.play(animation_name + "_" + finish_direction)
		
	#object_to_move.process_mode = Node.PROCESS_MODE_ALWAYS #Ensures object can be moved during dialog pause
	if timing_method == METHOD.SPEED:
		move_duration = distance_to_target / move_speed
	elif timing_method == METHOD.DURATION:
		move_speed = distance_to_target / move_duration
	
	if scale_animation_with_movement: 
		var anim_speed_scale:float=move_speed / animation_speed_factor
		player.animation_player.speed_scale = anim_speed_scale
			

	var tween : Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) #ensures tween can run. IMPORTANT!
	tween.set_ease(easing_method)
	tween.set_trans(transition_type)
	tween.tween_property(player, "global_position", target_location, move_duration)
	await get_tree().create_timer(move_duration).timeout
	#tween.tween_callback(_on_tween_finished)
	player.animation_player.speed_scale = 1.0
	await get_tree().process_frame
	if forced_finish_direction != null:
		finish_direction = forced_finish_direction
		GlobalPlayerManager.player.cardinal_direction = update_player_direction(forced_finish_direction)
		GlobalPlayerManager.player.direction = update_player_direction(forced_finish_direction)
		GlobalPlayerManager.player.set_direction()
		if finish_direction == "left":
			finish_direction = "right"
			GlobalPlayerManager.player.sprite.scale.x = -1
			
		player.animation_player.play("idle_" + finish_direction)
	
	_on_tween_finished()
	pass

func update_direction_name()->void:	
	var threshold : float = 0.45
	if move_direction.y < -threshold:
		finish_direction = "up"
	elif move_direction.y > threshold:
		finish_direction = "down"
	elif move_direction.x > threshold or move_direction.x < -threshold:
		finish_direction = "right"
		if move_direction.x < 0:
			GlobalPlayerManager.player.sprite.scale.x = -1
		elif move_direction.x > 0:
			GlobalPlayerManager.player.sprite.scale.x = 1
			
func update_player_direction(_fd:String)->Vector2:
	if _fd == "up":
		return Vector2.UP
	elif _fd == "down":
		return Vector2.DOWN
	elif _fd == "right":
		return Vector2.RIGHT
	elif _fd == "left":
		return Vector2.LEFT
	else:
		return Vector2.ZERO


func camera_to_player()->void:
	var camera:Camera2D = get_viewport().get_camera_2d()
	if camera:
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
		tween.tween_property(camera, "global_position", target_location, move_duration / 2)
		camera.reparent(GlobalPlayerManager.player) #assigns camera to new parent
		await get_tree().process_frame
		camera.position_smoothing_enabled = true #makes sure the camera moves normally after
	else:
		printerr("CAMERA NOT FOUND!")
	pass
func _on_tween_finished()->void:
	if reset_camera_to_player == true:
		camera_to_player()
	finished.emit() #Signal exists in the parent class CutSceneAction
	pass

func _draw()->void:
	if Engine.is_editor_hint():
		draw_circle( Vector2.ZERO, 3.0, Color.GREEN)
		draw_circle( Vector2.ZERO, 10.0, Color(0.557, 0.455, 0.4, 1.0), false, 1.0)
	pass
