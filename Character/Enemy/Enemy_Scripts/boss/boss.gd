class_name Boss extends CharacterBody2D

@onready var cloak = %Cloak
@onready var left_hand = %LeftHand
@onready var right_hand = %RightHand
@onready var cast_marker_left = %CastMarkerLeft
@onready var cast_marker_right = %CastMarkerRight
@onready var attack_1 = %Attack1
@onready var attack_2 = %Attack2
@onready var big_attack = %BigAttack
@export var hp:int=20
@onready var boss_state_machine = $StateMachine
@onready var teleport = %Teleport
@onready var animation_player = %AnimationPlayer
@onready var hit_box = %HitBox
@onready var collision_shape_2d = %CollisionShape2D
@onready var death = %Death
@onready var timer_1 = %Timer1
@onready var boss_data_handler = %BossDataHandler


var invulnerable:bool=false
var teleport_markers:Array[TeleportMarker2D]=[]
var torches:Array[Torch]=[]
var is_casting:bool=false
var is_dead:bool=false
var has_seen_player:bool=false


signal boss_damaged
signal boss_destroyed
signal boss_is_gone


func _process(_delta)->void:

	pass

func _ready()->void:
	get_teleport_markers()
	get_torches()
	boss_state_machine.initialize(self)
	hit_box.damaged.connect(_take_damage)
	boss_destroyed.connect(_death_state_change)
	boss_destroyed.connect((func _on_boss_destroyed(): boss_data_handler.set_value()))
	_on_data_loaded()
	if is_dead:
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		boss_is_gone.emit()
		queue_free()
		
func get_teleport_markers()->void:
	for child in get_tree().current_scene.get_children():
		if child is TeleportMarker2D:
			teleport_markers.append(child)

func get_torches()->void:
	for child in get_tree().current_scene.get_children():
		if child is Torch:
			torches.append(child)
			
			
func _take_damage(_hurt_box) -> void:
	if _hurt_box is StunHurtBox:
		return
	if invulnerable == true:
		return
	hp -= _hurt_box.damage
	if hp > 0:
		boss_damaged.emit()
	else:
		boss_destroyed.emit()
		
func is_casting_true()->void:
	is_casting=true

func is_casting_false()->void:
	is_casting=false


func _death_state_change()->void:
	boss_state_machine.change_state(death)
	
func _on_data_loaded()->void:
	is_dead = boss_data_handler.value
