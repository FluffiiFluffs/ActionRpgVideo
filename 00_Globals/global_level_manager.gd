extends Node

signal tilemap_bounds_changed(bounds : Array[Vector2])
##Fires when level loading is started
signal level_load_started
##Fires when level loading has completed
signal level_load_completed

var current_tilemap_bounds: Array[Vector2]
##Stores reference to the area to be transitioned to ("LevelTransition")
var target_transition: String
##Positions player
var position_offset: Vector2
var title_screen_active:bool=false


func change_tilemap_bounds (bounds : Array[Vector2] ) -> void:
	current_tilemap_bounds = bounds
	tilemap_bounds_changed.emit(bounds)
	
##Loads the new level. [br]
##Pauses game.[br]
##target_transition set. position_offset set.[br]
##Begins playing level loading transition(global scene)....and it plays.[br]
##Emits level_load_started signal.[br]
#awaits process frame (so current level gets removed).[br]
## change_scene_to_file(level_path). [br]
##Scene transition ends here.[br]
##Unpause game. Await process frame.[br]
##emits level_load_completed signal
func load_new_level(level_path : String,_target_transition: String,	_position_offset: Vector2) -> void:
	#if level_path == null: #prevents game loading...
		#return
	#if _target_transition == "": #prevents game loading...
		#return
	title_screen_active = false
	get_tree().paused = true
	target_transition = _target_transition
	position_offset = _position_offset
	await SceneTransition.fade_out()
	level_load_started.emit()
	await get_tree().process_frame
	get_tree().change_scene_to_file(level_path)
	#GlobalPlayerManager.set_player_position( position_offset )
	await SceneTransition.fade_in()
	get_tree().paused = false
	await get_tree().process_frame
	_clear_ui_focus()
	level_load_completed.emit()
	

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	level_load_completed.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _clear_ui_focus() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null:
		focused.release_focus()
