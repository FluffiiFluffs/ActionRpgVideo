##Attachable scene to an object that can be picked up and thrown.[br]
##Needs to have a hurtbox as a child to do damage to enemies (not attached by default)[br]
##This script handles all the "physics", not the thing throwing it.[br]
class_name Throwable
extends Area2D

@export var gravity_strength:float= 65.0
@export var throw_speed:float=350.0
@onready var wall_detect_collision_shape_2d = %WallDetectCollisionShape2D
@onready var wall_detect_character_body_2d = %WallDetectCharacterBody2D

var picked_up:bool=false
var prop:Node2D #reference to parent object
var _hurt_box:HurtBox #prop.hurt_box
var _animation_player : AnimationPlayer #prop.animation_player
var direction_when_thrown:Vector2
var is_thrown:bool=false
var is_destroyed:bool = false

signal prop_picked_up

func _ready()->void:
	prop = get_parent()
	setup_hurtbox()
	setup_animation_player()
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	_hurt_box.touched_something.connect(destroy)
	
func _physics_process(delta)->void:
	if is_destroyed == true:
		return
	if is_thrown == true:
		#how far the prop is from the player on the x axis
		var _from_player_x :float = absf(prop.global_position.x - GlobalPlayerManager.player.global_position.x)
		#how far the prop is from the player on the y axis
		var _from_player_y :float= absf(prop.global_position.y - GlobalPlayerManager.player.global_position.y)
		#argument for move_and_collide
		var motion = throw_speed * direction_when_thrown * delta
		#is true if move and collide is colliding
		var hit =	wall_detect_character_body_2d.move_and_collide(motion, true)
		if hit:
			if _hit_is_layer_(hit):
				is_destroyed = true #sets to destroyed so process stops
				destroy() #plays destroy animation
		prop.global_position += throw_speed * direction_when_thrown * delta
		if direction_when_thrown == Vector2.RIGHT or direction_when_thrown == Vector2.LEFT:
			if _from_player_x > 50:
				prop.global_position.y += gravity_strength * delta
		if _from_player_x > 200:
			is_destroyed = true
			destroy()
		if _from_player_y > 150:
			is_destroyed = true
			destroy()
	else:
		return

	
func setup_hurtbox()->void:
	#await get_tree().process_frame #possibly not needed
	for child in get_children():
		if child is HurtBox:
			_hurt_box = child as HurtBox
	if _hurt_box != null:
		_hurt_box.set_deferred("monitoring",false)
		#_hurt_box.monitoring = false
	wall_detect_collision_shape_2d.disabled = true
	

func setup_animation_player()->void:
		for child in prop.get_children():
			if child is AnimationPlayer:
				_animation_player = child

func throw()->void:
	#remove prop from player
	prop.get_parent().remove_child(prop)
	#add prop as sibling of player in scene.
	#call deferred needed or there's errors when changing states
	GlobalPlayerManager.player.call_deferred("add_sibling",prop)
	#_current_scene.call_deferred("add_child",prop)
	wall_detect_collision_shape_2d.set_deferred("disabled", false)
	#wall_detect_character_body_2d.set_collision_mask_value(5, true)
	#if hurtbox
	if _hurt_box != null:
		#turn on hurtbox
		#_hurt_box.monitoring = true
		_hurt_box.set_deferred("monitoring",true)
	direction_when_thrown = GlobalPlayerManager.player.cardinal_direction
	prop.global_position = GlobalPlayerManager.player.held_item_marker_2d.global_position
	#Small adjustment to make sure enemies get hit if they're really close
	prop.global_position.y += 12
	is_thrown = true
	prop.sprite_2d.z_index = 1
	GlobalPlayerManager.player.held_prop = null
	GlobalPlayerManager.player.held_prop_throwable = null

func destroy()->void:
	_hurt_box.set_deferred("monitoring",false)
	#_hurt_box.monitoring = false
	is_destroyed = true
	print("DESTROY")
	#stop dropping on y axis
	#play destroy animation
	prop.animation_player.play("destroy")
	await prop.animation_player.animation_finished
	prop.queue_free()

func player_interact()->void:
	#prevents picking up two!
	if GlobalPlayerManager.player.held_prop !=null:
		return
	if picked_up == false:
		if prop.get_parent():
			prop.get_parent().remove_child(prop)
		prop.collision_shape_2d.disabled = true
		GlobalPlayerManager.player.held_item_marker_2d.add_child(prop)
		prop.global_transform = GlobalPlayerManager.player.held_item_marker_2d.global_transform
		GlobalPlayerManager.player.pickup_item(self)
		area_entered.disconnect(_on_area_entered)
		area_exited.disconnect(_on_area_exited)
		GlobalPlayerManager.player.held_prop = prop
		GlobalPlayerManager.player.held_prop_throwable = self
		prop_picked_up.emit()

#for picking up
func _on_area_entered(_area:Area2D)->void:
	GlobalPlayerManager.interact_pressed.connect(player_interact)

#after picking up
func _on_area_exited(_area:Area2D)->void:
	GlobalPlayerManager.interact_pressed.disconnect(player_interact)

##makes the characterbody2d node determine what layer it touched during collision
func _hit_is_layer_(hit: KinematicCollision2D) -> bool:
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
	return (layers & (L5)) != 0	
	
