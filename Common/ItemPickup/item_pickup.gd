##Generic item pickup scene
##CharacterBody2D as root node due to needing to move/bounce
@tool
class_name ItemPickup
extends CharacterBody2D

@onready var area_2d = %Area2D
@onready var sprite_2d = %Sprite2D
@onready var audio_stream_player_2d = %AudioStreamPlayer2D
@onready var player_detect_area = %PlayerDetectArea2D
@onready var animation_player = %AnimationPlayer
@export var item_data : ItemData : set = _set_item_data
##If the item picked up needs a special sound
@export var item_player_far_scale : Vector2 = Vector2(1.0,1.0)
@export var item_player_near_scale : Vector2 = Vector2(1.2,1.2)
##Default pickup sound used
const ITEM_COLLECTED = preload("uid://c64lljryccy1y") #default pickup sound
##Uses a default sound but ItemData resources can define their own sound (ItemData.sound_effect)
@export var sound_effect :AudioStream= ITEM_COLLECTED
var boomerang : Boomerang
var boomerang_attached : bool = false

signal picked_up

##uses move_and_collide to bounce off walls
##NOTE: collision_info.get_normal() gets the direction of the collision
##bounce() sets the velocity the the OPPOSITE 
func _physics_process(delta):
	var collision_info = move_and_collide(velocity*delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
	velocity -= velocity * delta * 4
	if boomerang_attached:
		if boomerang != null:
			#print("!!!")
			global_transform = boomerang.global_transform

func _ready() -> void:
	boomerang_attached = false
	_update_texture()
	_update_sound()
	#area_2d.monitoring = false
	#area_2d.monitorable = false
	area_2d.body_entered.connect(_on_body_entered)
	#player_detect_area.body_entered.connect(_on_player_detected)
	#player_detect_area.body_exited.connect(_on_player_undetected)
	#await get_tree().process_frame
	#area_2d.set_deferred("monitoring",true)
	#area_2d.set_deferred("monitorable", true)

	if Engine.is_editor_hint():
		return

func _on_body_entered(body) -> void:
	if body is Player:
		if item_data:
			if item_data.use_on_pickup==false:
			#returns bool, checks for inventory resource
				if GlobalPlayerManager.INVENTORY_DATA.add_item(item_data): 
					item_picked_up()
			elif item_data.use_on_pickup==true:
				##use the item immediately, do not put in inventory
				item_data.use()
				item_picked_up()
				pass
	if body is Boomerang:
		boomerang_attached = true
		boomerang = get_tree().current_scene.get_node_or_null("Boomerang")
		body.has_item = true
		body.current_state = body.State.RETURN

##Updates the sound effect[br]
##Default sound used if none is set within item_data's resource
func _update_sound():
	if item_data.sound_effect == null:
		sound_effect = ITEM_COLLECTED
	elif item_data.sound_effect != null:
		sound_effect = item_data.sound_effect

		
		
func item_picked_up() -> void:
	if boomerang != null:
		boomerang.queue_free()
	area_2d.body_entered.disconnect(_on_body_entered)
	await get_tree().process_frame
	audio_stream_player_2d.stream = sound_effect
	audio_stream_player_2d.play()
	visible = false
	picked_up.emit()
	await audio_stream_player_2d.finished
	queue_free()
	

func _update_texture() -> void:
	#checks if item data has a sprite
	if item_data and sprite_2d:
		sprite_2d.texture = item_data.texture



func _set_item_data (value:ItemData ) -> void:
	_update_texture()
	item_data = value
#
#func _on_player_detected(body:Player):
	#if body is not Player:
		#return
	#if body is Player:
		#var tween = create_tween()
		#tween.set_ease(Tween.EASE_IN_OUT)
		#tween.set_trans(Tween.TRANS_QUAD)
		#tween.tween_property(sprite_2d, "scale", item_player_near_scale, 0.3)
		#
#func _on_player_undetected(body:Player):
	#if body is not Player:
		#return
	#if body is Player:
		#var tween = create_tween()
		#tween.set_ease(Tween.EASE_IN_OUT)
		#tween.set_trans(Tween.TRANS_QUAD)
		#tween.tween_property(sprite_2d, "scale", item_player_far_scale, 0.3)
