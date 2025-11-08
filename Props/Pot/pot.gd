class_name Pot
extends Node2D
@onready var collision_shape_2d = %CollisionShape2D
@onready var animation_player = %AnimationPlayer
@onready var sprite_2d = %Sprite2D
@export_category("Item Drops")
@export var drops : Array [DropData]
const PICKUP = preload("uid://cbpnajsqw23v8")
@onready var throwable = %Throwable

var original_position:=Vector2.ZERO


func _ready()->void:
	original_position = global_position
	throwable.prop_picked_up.connect(drop_items)

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
