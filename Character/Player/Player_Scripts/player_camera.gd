class_name PlayerCamera
extends Camera2D


@export_range(0, 1, 0.05, "or_greater") var shake_power:float=0.5 ##overall shake strength
@export var shake_max_offset:float=5.0 ##max movement of camera
@export var shake_decay:float=1.0 ##how quickly shake stops
@export var shake_enabled: bool = true:
	set = _set_shake_enabled, get = _get_shake_enabled



var shake_trauma:float=0.0



# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalLevelManager.tilemap_bounds_changed.connect(_update_limits)
	_update_limits( (GlobalLevelManager.current_tilemap_bounds))
	GlobalPlayerManager.camera_shook.connect(add_camera_shake)
	pass # Replace with function body.

func _physics_process(delta)->void:
	if shake_trauma > 0:
		shake_trauma = max(shake_trauma - shake_decay * delta, 0)
		shake()
		
		pass
		

func shake()->void:
	var amount : float = pow(shake_trauma * shake_power,2)
	offset = Vector2(randf_range(-1,1),randf_range(-1,1)) * shake_max_offset * amount
	#print("Camera Shaking")
	pass
	
func add_camera_shake(_shake_val:float)->void:
	if shake_enabled:
		shake_trauma = _shake_val
	pass


func _update_limits(bounds:Array[Vector2]) -> void:
	if bounds == []:
		return 
	limit_left = int(bounds[0].x)
	limit_top = int(bounds[0].y)
	limit_right = int(bounds[1].x)
	limit_bottom = int(bounds[1].y)

func _set_shake_enabled(value: bool) -> void:
	# This assignment writes the storage without re-invoking the setter
	shake_enabled = value
	#print("File: player_camera.gd ", " Shake: " + str(value))

func _get_shake_enabled() -> bool:
	return shake_enabled
