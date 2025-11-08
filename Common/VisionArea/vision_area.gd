##Script attached to vision_area.tscn[br][br]
##This script is used to control the direction of the vision cone and emits signals when the player enters and exits the area.[br]
##This scene is meant to be dragged into a scene of an enemy.[br]
##The collision shape of this node is to be defined after it is placed in a scene.[br][br]
##Monitorable set to false, only tries to detect other areas[br][br]
##Mask = Player layer[br][br]
##[gdscript]USE A CollisionPolygon2D node for this![/gdscript]
class_name VisionArea
extends Area2D

signal player_entered()
signal player_exited()

func _ready()-> void:
	#body_entered.connect(_on_body_entered)
	#body_exited.connect(_on_body_exited)
	var _parent = get_parent()
	if _parent is Enemy:
		_parent.direction_changed.connect(_on_direction_change)
	check_for_player_timer()

func check_for_player_timer():
	var timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 0.15
	add_child(timer)
	timer.timeout.connect(func check():
		if overlaps_body(GlobalPlayerManager.player):
			#print("PLAYER OVERLAPPING")
			player_entered.emit()
		elif !overlaps_body(GlobalPlayerManager.player):
			player_exited.emit()
			)
		
func _on_body_entered(body:Player) -> void:
	if body is Player:
		player_entered.emit()

func _on_body_exited(body:Player) -> void:
	if body is Player:
		player_exited.emit()

##Function for setting the direction of the cone.[br]
##Simply rotates the Area2D root node of this scene, which rotates the child (defined in the scene this is attached to).[br]
##new_direction argument passed from [code]Enemy[/code].direction_changed signal
func _on_direction_change(new_direction : Vector2):
	match new_direction:
		Vector2.DOWN:
			rotation_degrees = 0
		Vector2.UP:
			rotation_degrees = 180
		Vector2.LEFT:
			rotation_degrees = 90
		Vector2.RIGHT:
			rotation_degrees = -90
		_:
			rotation_degrees = 0
			
