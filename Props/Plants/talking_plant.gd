class_name TalkingPlant
extends Node2D

@onready var audio_stream_player = %AudioStreamPlayer
@onready var hit_box = %HitBox
@onready var plant_sprite_2d = %PlantSprite2D
const GRASS = preload("uid://fukbh6i74qno")

func _ready()->void:
	hit_box.damaged.connect(shake)
	
	
func shake(_hurt_box)->void:
	if _hurt_box is HurtBox:
		audio_stream_player.stream = GRASS
		audio_stream_player.play()
		plant_sprite_2d.material.set_shader_parameter("shake_intensity", 3)
		await get_tree().create_timer(0.2).timeout
		plant_sprite_2d.material.set_shader_parameter("shake_intensity", 0.0)
		print("PLANT HIT")

#const PICKUP = preload("res://Props/ItemPickup/item_pickup.tscn")
#
#@export_category("Item Drops")
#@export var drops : Array [DropData]
#
#@onready var hit_box :HitBox= %HitBox
#@onready var animation_player:AnimationPlayer = %AnimationPlayer
#@onready var audio_stream_player_2d :AudioStreamPlayer2D= %AudioStreamPlayer2D
#@onready var static_body_2d :StaticBody2D= %StaticBody2D
#@onready var static_body_collision_shape_2d:CollisionShape2D = %StaticBodyCollisionShape2D
#
#
## Called when the node enters the scene tree for the first time.
#func _ready():
	#hit_box.damaged.connect(on_damage_taken)
#
#func on_damage_taken(_damage) -> void:
	#if _damage is HurtBox:
		#call_deferred("static_body_disable")
		#audio_stream_player_2d.play()
		#animation_player.play("destroy")
		#drop_items()
		#await get_tree().create_timer(0.8).timeout
		#call_deferred("destroy")
	#else:
		#return
	#
#func destroy():
	#queue_free()
#
#func static_body_disable():
	#static_body_collision_shape_2d.disabled = true
#
#func drop_items() -> void:
	#if drops.size() == 0:
		#return
	#for i in drops.size():
		#if drops[i] == null or drops[i].item == null:
			#continue #skips, and continues for loop
		#var drop_count: int = drops[i].get_drop_count()
		#for j in drop_count:
			#var drop : ItemPickup = PICKUP.instantiate() as ItemPickup
			#drop.item_data = drops[i].item
			#get_tree().current_scene.call_deferred("add_child", drop)
			#drop.global_position = global_position
			#var drop_sprite := drop.get_node_or_null("Sprite2D")
			#var drop_scale_time :float= 0.1
			#drop_sprite.scale = Vector2(0.25,0.25)
			#var tween:= create_tween()
			#tween.set_parallel()
			#tween.tween_property(drop_sprite, "scale", Vector2(1.0,1.0), drop_scale_time)
