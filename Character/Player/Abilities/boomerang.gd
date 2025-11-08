class_name Boomerang
extends CharacterBody2D

@onready var sparkle_marker_2d = %SparkleMarker2D
@onready var animation_player = %AnimationPlayer
@onready var boomerang_audio = %BoomerangAudio
@onready var wall_collision_shape_2d = %WallCollisionShape2D


const TINK = preload("uid://di4uau7in0rkt")
enum State{ INACTIVE, THROW, RETURN }

@export var acceleration : float = 500.0
@export var max_speed : float = 400.0
@export var max_distance: float = 450.0
@export var _b_timer_time : float = 2.75

var player: Player
var direction : Vector2
var current_speed: float = 0
var current_state
var distance_traveled : float = 0
var _b_timer :Timer
var has_item : bool = false

const SPARKLEANIM = preload("uid://dn1dusllgk06h")
const DEFLECT_EFFECT = preload("uid://b7ndm8gwlvrds")

func _ready() -> void:
	_boomerang_timer(_b_timer_time)
	_b_timer.timeout.connect(queue_free)
	visible = false
	current_state = State.INACTIVE
	player = GlobalPlayerManager.player

func _physics_process(delta:float) -> void:
	match current_state:
		State.THROW:
			# planned motion this frame
			var motion := direction * current_speed * delta
			# test-only sweep so we do not move twice
			var hit := move_and_collide(motion, true)
			if hit:
				if _hit_is_layer_5_or_10(hit):
					GlobalPlayerManager.player.audio_stream_player_2d.stream = TINK
					GlobalPlayerManager.player.audio_stream_player_2d.play()
					#tink_audio.play()
					make_deflect()
				current_state = State.RETURN
			else:
				var collision_info = move_and_collide(velocity*delta)
				if collision_info:
					current_state = State.RETURN
				# no blocking layers hit, advance normally
				position += motion
				distance_traveled += current_speed * delta
				if distance_traveled >= max_distance:
					current_state = State.RETURN

		State.RETURN:
			move_and_slide() # keep existing behavior
			wall_collision_shape_2d.set_deferred("disabled",true)
			direction = global_position.direction_to(player.global_position + Vector2(0, -10))
			position += direction * current_speed * delta
			var distance_to_player = global_position.distance_to(player.global_position)
			if !has_item:
				if distance_to_player <= 15:
					queue_free()

func throw(throw_direction: Vector2) -> void:
	direction = throw_direction
	current_speed = max_speed
	current_state = State.THROW
	animation_player.play("throw")
	visible = true
	boomerang_audio.play()
	await get_tree().create_timer(0.2).timeout

func make_deflect() -> void:
	var _deflect = DEFLECT_EFFECT.instantiate()
	get_tree().current_scene.add_child(_deflect)
	_deflect.global_transform = sparkle_marker_2d.global_transform
	

func make_sparkle() -> void:
	var _sparkle = SPARKLEANIM.instantiate()
	get_tree().current_scene.add_child(_sparkle)
	_sparkle.global_transform = sparkle_marker_2d.global_transform
	#var s_anim = _sparkle.get_node_or_null("AnimationPlayer")
	#s_anim.play("twinkle")
	#await s_anim.animation_finished
	#_sparkle.queue_free()

func _boomerang_timer(time:float):
	_b_timer = Timer.new()
	_b_timer.wait_time = time
	_b_timer.one_shot = true
	_b_timer.autostart = true
	add_child(_b_timer)
	
	
func _hit_is_layer_5_or_10(hit: KinematicCollision2D) -> bool:
	var rid := hit.get_collider_rid()
	if rid == RID():
		return false
	var layers := 0
	var collider := hit.get_collider()
	if collider is Area2D:
		layers = PhysicsServer2D.area_get_collision_layer(rid)
	else:
		layers = PhysicsServer2D.body_get_collision_layer(rid)
	const L5  := 1 << (5 - 1)
	const L10 := 1 << (10 - 1)
	return (layers & (L5 | L10)) != 0	
	
