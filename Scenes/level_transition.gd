@tool
class_name LevelTransition
extends Area2D

enum SIDE {LEFT, RIGHT, TOP, BOTTOM}
##LocalToScene = true
@onready var collision_shape :CollisionShape2D= %CollisionShape2D

##Level to be loaded when area entered
@export_file("*.tscn") var level
##Used to point player where to spawn on the level loaded
@export var target_transition_area: String = "LevelTransition"
##Player appears at the center of the next target_transition_area node.[br]
##Otherwise, player will appear in the same place as where it exited.
@export var center_player : bool = true
@export_category("Collision Area Settings")
##Controls size of the collision shape.
##Updates in scene when changed in inspector
@export_range(1,12,1, "or_greater") var size : int = 2 :
	set(_value):
		size = _value
		_update_area()
##Which side of the screen the LevelTransition is on.
##Updates in scene when changed in inspector
@export var side: SIDE = SIDE.LEFT:
	set(_value):
		side = _value
		_update_area()
		
##Snaps collision shape to grid. Use like a button, is not a toggle.
@export var snap_to_grid : bool = false:
	set(_value):
		_snap_to_grid()
##Needs to be set to default tile size for the tilemap being used
@export var tile_size : int = 32
@export var delete_on_load: bool = false

signal entered_from_here

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_area()
	#if within the editor, do nothing
	if Engine.is_editor_hint():
		return
	#Turns off monitoring for player so next scene can load
	monitoring = false
	_place_player()
	await GlobalLevelManager.level_load_completed ##level_load_completed signal emitted in GlobalLevelManager script on ready
	await get_tree().physics_frame
	await get_tree().physics_frame
	monitoring = true
	body_entered.connect(_on_player_entered)
	if delete_on_load == true:
		queue_free()
		return

##Utilizes GLOBAL LEVEL MANAGER AUTOLOAD.
##loads level, places player at an offset of the target_transition_area
func _on_player_entered(_player:Node2D) -> void:
	if level == null:
		printerr("NEED LEVEL SCENE SET FOR: " + str(name))
	else:
		GlobalLevelManager.load_new_level(level, target_transition_area, get_offset())

func _change_level() -> void:
	if level == null:
		printerr("NEED LEVEL SCENE SET FOR: " + str(name))
	else:
		GlobalLevelManager.load_new_level(level, target_transition_area, get_offset())
	
	
##Creates a new rectangle shape based on inspector values
##Tile size should be set to the size of the tilemap's tiles
func _update_area() -> void:
	var new_rect : Vector2 = Vector2(tile_size,tile_size)
	var new_position: Vector2 = Vector2.ZERO
	if side == SIDE.TOP:
		new_rect.x *= size
		new_position.y -= (tile_size*0.5)
	elif side == SIDE.BOTTOM:
		new_rect.x *= size
		new_position.y += (tile_size*0.5)
	elif side == SIDE.LEFT:
		new_rect.y *= size
		new_position.x -= (tile_size*0.5)
	elif side == SIDE.RIGHT:
		new_rect.y *= size
		new_position.x += (tile_size*0.5)
	#Important due to this being @tool	
	if collision_shape == null:
		collision_shape = get_node("CollisionShape2D")
	collision_shape.shape.size = new_rect
	collision_shape.position = new_position
##Snaps collision shape to grid.[br] Use as toggle button.
func _snap_to_grid() -> void:
	position.x = round(position.x / (tile_size*0.5))*(tile_size*0.5)
	position.y = round(position.y / (tile_size*0.5))*(tile_size*0.5)

##Sets offset in relation to the side property of the level_transition node.[br]
##Places player one tile away from the collision_shape.[br]
## offset.x/y can be adjusted further if needed to account for player collision shape size.
func get_offset() -> Vector2:
	var offset : Vector2 = Vector2.ZERO
	var player_pos = GlobalPlayerManager.player.global_position
	
	if side == SIDE.LEFT or side == SIDE.RIGHT:
		if center_player == true:
			offset.y = 0
		else:
			offset.y = player_pos.y - global_position.y
		offset.x = tile_size ##change this value if player ping pongs
		if side == SIDE.LEFT:
			offset.x *= -1
	else:
		if center_player == true:
			offset.x = 0
		else:
			offset.x = player_pos.x - global_position.x
		offset.y = tile_size ##change this value if player ping pongs
		if side == SIDE.TOP:
			offset.y *= -1

	return offset

##Checks if the target_transition_area is correct
##Uses set_player_position function in GlobalPlayerManager
func _place_player() -> void:
	if name != GlobalLevelManager.target_transition:
		return
	GlobalPlayerManager.set_player_position( global_position + GlobalLevelManager.position_offset )
	entered_from_here.emit()	
