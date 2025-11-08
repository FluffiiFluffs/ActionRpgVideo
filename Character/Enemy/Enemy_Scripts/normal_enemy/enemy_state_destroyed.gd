class_name EnemyStateDestroyed extends EnemyState

const PICKUP = preload("uid://cbpnajsqw23v8")


@export var attack_hurtbox :HurtBox
@export var anim_name : String = "destroy"
@export var knockback_speed : float = 200.0
@export var decelerate_speed : float = 10.0
@onready var hurt_box = %HurtBox
@onready var collision_shape_2d = %CollisionShape2D


@export_category("Item Drops")
@export var drops : Array [DropData]

var _direction : Vector2
var _damage_position : Vector2

##What happens when state is initialized
func init() -> void:
	enemy.enemy_destroyed.connect(_on_enemy_destroyed)

func _ready() -> void:
	pass
	
## What happens when the state is entered
func enter() -> void:
	disable_hurt_box()
	enemy.invulnerable = true #Ensures enemy takes no more damage once dead
	_direction = enemy.global_position.direction_to(_damage_position)
	enemy.set_direction(_direction)
	enemy.velocity = _direction * -knockback_speed
	enemy.update_animation(anim_name)
	drop_items()
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	pass
## What happens when the state is exited
func exit() -> void:
	pass
	
## What happens during _process(): update while state is running
func process (delta : float) -> EnemyState:
	enemy.velocity -= enemy.velocity * decelerate_speed * delta	
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> EnemyState:
	return null	

func _on_enemy_destroyed(_hurt_box : HurtBox) -> void:
	_damage_position = _hurt_box.global_position
	state_machine.change_state(self)
	
func _on_animation_finished(_a : String):
	await get_tree().create_timer(0.5,false).timeout
	enemy.queue_free()


##Checks if there is a node named "HurtBox" in enemy's tree[br]
##If there is a hurtbox, turns monitoring off.[br]
func disable_hurt_box() -> void:
	var _hurt_box : HurtBox = enemy.get_node_or_null("HurtBox")
	if _hurt_box:
		hurt_box.monitoring = false
	if attack_hurtbox != null:
		attack_hurtbox.monitoring = false
	if collision_shape_2d != null:
		collision_shape_2d.queue_free()

func drop_items() -> void:
	if drops.size() == 0:
		return
	for i in drops.size():
		if drops[i] == null or drops[i].item == null:
			continue #skips, and continues for loop
		var drop_count: int = drops[i].get_drop_count()
		for j in drop_count:
			#await get_tree().process_frame #not here, causes item not to work...
			var drop : ItemPickup = PICKUP.instantiate() as ItemPickup
			drop.item_data = drops[i].item
			drop.global_position = enemy.global_position
			var random_angle :float= randf_range(-1.5, 1.5)
			var dropvelocity = enemy.velocity.rotated(random_angle) * randf_range(0.5,1.5)
			enemy.get_parent().call_deferred("add_child", drop)
			#get_tree().current_scene.add_child(drop)
			#get_tree().current_scene.call_deferred("add_child" ,drop)
			#enemy.get_parent().add_child(drop)
			await get_tree().process_frame
	
			#uses enemy knockback velocity to set velocity of drop
			drop.velocity = dropvelocity
			#var anim_player :AnimationPlayer= drop.get_node_or_null("AnimationPlayer")
			var anim_player :AnimationPlayer= drop.animation_player
			#drop.area_2d.set_deferred("monitoring", false)
			anim_player.play("bounce")
			#await anim_player.animation_finished
			#var drop_sprite = drop.get_node_or_null("Sprite2D")
			#var drop_scale_time :float= 0.5
			#drop_sprite.scale = Vector2(0.25,0.25)
			#var tween:= create_tween()
			#tween.set_parallel()
			#tween.tween_property(drop_sprite, "scale", Vector2(1.0,1.0), drop_scale_time)
			#await tween.finished
			#drop.area_2d.set_deferred("monitoring", true)
	
