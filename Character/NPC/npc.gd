@icon("res://ASSETS/Icons/npc.svg")
class_name NPC
extends CharacterBody2D

@onready var sprite_2d :Sprite2D= %Sprite2D
@onready var animation_player :AnimationPlayer= %AnimationPlayer
@onready var npc_state_machine:NPCStateMachine = %NPCStateMachine
@onready var idle:NPCState = %Idle
@onready var wander:NPCState = %Wander
@onready var p_det_area_2d:Area2D = %PDetArea2D
@export var npc_resource : NPCResource : set = _set_npc_resource
@export var npc_can_wander : bool = false
@export var npc_will_patrol:bool = false 
@onready var patrol :NPCState= %Patrol
@onready var collision_shape_2d :CollisionShape2D= %CollisionShape2D
@onready var coll_timer :Timer= %CollTimer

const DIR_4 : Array = [ Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP ]
var player : Player
var state :String = "idle"
var direction :Vector2 = Vector2.DOWN
var direction_name :String = "down"
var do_behavior :bool= true
var player_detected :bool= false
#var is_talking : bool = false
var wait_time :float

#signal tells the behavior scripts if they are enabled or not
signal player_is_detected
signal player_is_not_detected


func _ready()-> void:
	if npc_will_patrol == true:
		npc_can_wander = false
	npc_state_machine.initialize(self)
	player = GlobalPlayerManager.player
	player_is_detected.connect(_collision_shape_off)
	player_is_not_detected.connect(_collision_shape_on)
	coll_timer.timeout.connect(_coll_shape_disable)
	setup_npc()
	check_for_player_timer()
	#gather_interactables()



func _collision_shape_off()->void:
	if coll_timer.is_stopped():
		coll_timer.start()

func _coll_shape_disable()->void:
	collision_shape_2d.disabled = true

func _collision_shape_on()->void:
	if coll_timer.time_left > 0:
		if player_is_not_detected:
			coll_timer.stop()
		collision_shape_2d.disabled = false

func _physics_process(_delta)->void:
	#print(str(coll_timer.time_left))
	move_and_slide()

func update_animation()->void:
	animation_player.play(state + "_" + direction_name)

#func patrol_update_animation()->void:
	#animation_player.play(patrol.pstate + "_" + direction_name)

func update_direction(_target_position:Vector2)->void:
	direction = global_position.direction_to(_target_position)
	update_direction_name()
	#anim_direction()
	#if direction_name == "right" and direction.x < 0:
		#sprite_2d.flip_h = true
	#else:
		#sprite_2d.flip_h = false

func update_direction_name()->void:	
	var threshold : float = 0.45
	if direction.y < -threshold:
		direction_name = "up"
	elif direction.y > threshold:
		direction_name = "down"
	elif direction.x > threshold or direction.x < -threshold:
		direction_name = "right"
		if direction.x < 0:
			sprite_2d.flip_h = true
		elif direction.x > 0:
			sprite_2d.flip_h = false
		
func anim_direction() -> void:
	if direction == Vector2.DOWN:
		direction_name = "down"
	elif direction == Vector2.UP:
		direction_name = "up"
	else:
		direction_name = "right"


func setup_npc()->void:
	if npc_resource:
		if sprite_2d:
			sprite_2d.texture = npc_resource.sprite_texture
			sprite_2d.hframes = npc_resource.sprite_hframes
			sprite_2d.vframes = npc_resource.sprite_vframes

func _set_npc_resource(_npc:NPCResource)->void:
	npc_resource = _npc
	setup_npc()
	
func check_for_player_timer():
	var timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 0.1
	add_child(timer)
	timer.timeout.connect(func check():
		if p_det_area_2d.overlaps_body(GlobalPlayerManager.player):
			#print("PLAYER OVERLAPPING")
			player_detected = true
			player_is_detected.emit()
		elif !p_det_area_2d.overlaps_body(GlobalPlayerManager.player):
			#print("PLAYER NOT OVERLAPPING")
			player_detected = false
			player_is_not_detected.emit()
			)
