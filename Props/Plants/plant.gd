class_name Plant
extends Node2D

const PICKUP = preload("uid://cbpnajsqw23v8")

@export_category("Item Drops")
@export var drops : Array [DropData]

@onready var hit_box :HitBox= %HitBox
@onready var animation_player:AnimationPlayer = %AnimationPlayer
@onready var audio_stream_player_2d :AudioStreamPlayer2D= %AudioStreamPlayer2D
@onready var static_body_2d :StaticBody2D= %StaticBody2D
@onready var collision_shape_2d:CollisionShape2D = %CollisionShape2D
@onready var sprite_2d = %Sprite2D
@onready var throwable = %Throwable

var original_position:Vector2=Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	original_position = global_position
	hit_box.damaged.connect(on_damage_taken)
	throwable.prop_picked_up.connect(drop_items)

func on_damage_taken(_damage) -> void:
	if _damage is HurtBox:
		for child in get_children():
			if child is Throwable:
				child.queue_free()
		call_deferred("static_body_disable")
		#audio_stream_player_2d.play()
		animation_player.play("destroy")
		drop_items()
		await get_tree().create_timer(0.8,false).timeout
		call_deferred("destroy")
	else:
		return
	
func destroy():
	queue_free()

func static_body_disable():
	collision_shape_2d.disabled = true

func drop_items() -> void:
	if drops.size() == 0:
		return
	for i in drops.size():
		if drops[i] == null or drops[i].item == null:
			continue #skips, and continues for loop
		var drop_count: int = drops[i].get_drop_count()
		for j in drop_count:
			var drop : ItemPickup = PICKUP.instantiate() as ItemPickup
			drop.item_data = drops[i].item
			get_tree().current_scene.call_deferred("add_child", drop)
			drop.global_position = original_position
			var drop_sprite := drop.get_node_or_null("Sprite2D")
			var drop_scale_time :float= 0.1
			drop_sprite.scale = Vector2(0.25,0.25)
			var tween:= create_tween()
			tween.set_parallel()
			tween.tween_property(drop_sprite, "scale", Vector2(1.0,1.0), drop_scale_time)
