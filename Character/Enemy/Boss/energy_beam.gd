class_name EnergyBeamSmall
extends Node2D
@onready var line_2d = %Line2D
@onready var audio_stream_player_2d = %AudioStreamPlayer2D
@onready var hurt_box = %HurtBox
@onready var collision_shape_2d = %CollisionShape2D
@onready var animation_player = %AnimationPlayer
@onready var timer = %Timer
const SHOOT = preload("uid://m752yfpmq213")
const CHARGE = preload("uid://blv5pa7glsy2y")
const SHOCK = preload("uid://cr34feejhxmic")
const BEAM = preload("uid://bpy3xnpbrlgyo")

var is_charging:bool=false

# Add these to the top level of your script
var _p0_animating: bool = false
var _p0_start: Vector2
var _p0_target: Vector2
var _p0_time: float = 0.0
var _p0_duration: float = 0.2


func _ready()->void:
	visible = false
	hurt_box.set_deferred("monitoring", false)
	hurt_box.touched_something.connect(_on_touched_something)

	# guarantee three points exist: 0, 1, 2
	if line_2d.get_point_count() < 3:
		var need = 3 - line_2d.get_point_count()
		while need > 0:
			line_2d.add_point(Vector2.ZERO)
			need -= 1
	# make points aligned at start
	var p0 = line_2d.get_point_position(0)
	line_2d.set_point_position(1, p0)
	line_2d.set_point_position(2, p0)

	charge()

func _physics_process(delta: float) -> void:
	if _p0_animating:
		_p0_time += delta
		var t := _p0_time / _p0_duration
		if t >= 1.0:
			t = 1.0
			_p0_animating = false
		var v := _p0_start.lerp(_p0_target, t)
		line_2d.set_point_position(0, v)
		# keep the hit segment in sync with point 0 if you want
		var seg := collision_shape_2d.shape as SegmentShape2D
		seg.a = v



func charge()->void:
	if GlobalPlayerManager.player.hp < 1:
		queue_free()
	hurt_box.set_deferred("monitoring",false)
	is_charging = true
	visible=true
	animation_player.play("charge")
	audio_stream_player_2d.stop()
	audio_stream_player_2d.stream = CHARGE
	audio_stream_player_2d.pitch_scale = 1.5
	audio_stream_player_2d.play()
	timer.wait_time = 2.0
	timer.start()
	await timer.timeout
	#await get_tree().create_timer(2.0).timeout
	audio_stream_player_2d.pitch_scale = 1.0
	animation_player.play("RESET")
	is_charging = false
	shoot()

func shoot()->void:
	hurt_box.set_deferred("monitoring", true)
	var _player := GlobalPlayerManager.player.global_position
	timer.wait_time = 0.15
	timer.start()
	await timer.timeout
	#await get_tree().create_timer(0.15).timeout
	play_audio(BEAM)

	var seg := collision_shape_2d.shape as SegmentShape2D
	seg.a = Vector2.ZERO
	seg.b = collision_shape_2d.to_local(_player)

	# move the middle point to the player in line_2d local space
	var p1 = line_2d.to_local(_player)
	line_2d.set_point_position(1, p1)

	# define the tip as point 2, same as p1
	line_2d.set_point_position(2, p1)

	# animate point 0 toward the last point
	_p0_start = line_2d.get_point_position(0)
	_p0_target = line_2d.get_point_position(line_2d.get_point_count() - 1) # index 2
	_p0_time = 0.0
	_p0_animating = true

	visible = true
	line_2d.visible = true
	timer.wait_time = 0.5
	timer.start()
	await timer.timeout
	#await get_tree().create_timer(0.5).timeout
	hurt_box.set_deferred("monitoring", false)
	timer.start()
	await timer.timeout
	#await get_tree().create_timer(0.5).timeout
	line_2d.visible = false
	timer.start()
	await timer.timeout
	#await get_tree().create_timer(0.5).timeout
	queue_free()

	
	

func _on_touched_something()->void:
	audio_stream_player_2d.stop()
	audio_stream_player_2d.stream = SHOCK
	audio_stream_player_2d.play()
	hurt_box.set_deferred("monitoring",false)
	timer.wait_time = 1.0
	timer.start()
	await timer.timeout
	#await get_tree().create_timer(1.0).timeout
	line_2d.visible = false
	queue_free()
	pass
	
func play_audio(_audio:AudioStream)->void:
	audio_stream_player_2d.stream = _audio
	audio_stream_player_2d.play()
