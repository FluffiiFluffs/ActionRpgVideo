##Attachable scene to an object that can be picked up and thrown.[br]
##Needs to have a hurtbox as a child to do damage to enemies (not attached by default)
#class_name Throwable
extends Area2D

@export var gravity_strength:float= 100.0
@export var throw_speed:float=450.0
@onready var wall_detect_collision_shape_2d = %WallDetectCollisionShape2D
@onready var wall_detect_character_body_2d = %WallDetectCharacterBody2D

@onready var drop_timer_1 = %DropTimer1
@onready var drop_timer_2 = %DropTimer2
@onready var up_down_drop_timer = %UpDownDropTimer


var picked_up:bool=false
var prop:Node2D #reference to parent object
var _hurt_box:HurtBox #prop.hurt_box
#var vertical_velocity:float=0 #not needed, handled by timer
#var ground_height:float=0 #not needed handled by timer
var _animation_player : AnimationPlayer #prop.animation_player
var is_dropping:bool=false
var direction_when_thrown
var is_thrown:bool=false
var is_destroyed:bool = false

func _ready()->void:
	prop = get_parent()
	setup_hurtbox()
	setup_animation_player()
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	drop_timer_1.timeout.connect(_drop_2)
	drop_timer_2.timeout.connect(destroy)
	up_down_drop_timer.timeout.connect(_updown_drop)
	_hurt_box.touched_something.connect(destroy)
func _physics_process(delta)->void:
	if is_destroyed == true:
		return
	if is_thrown == true:
		var motion = throw_speed * direction_when_thrown * delta
		var hit =	wall_detect_character_body_2d.move_and_collide(motion, true)
		if hit:
			if _hit_is_layer_(hit):
				is_destroyed = true
				destroy()
		prop.global_position += throw_speed * direction_when_thrown * delta
	else:
		return
	if is_dropping == true:
		prop.global_position.y += gravity_strength * delta
	elif is_dropping == false:
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
	var _current_scene = get_tree().current_scene
	#if !GlobalPlayerManager.player.state_machine.next_state:
	#remove prop from player
	prop.get_parent().remove_child(prop)
	#add prop as sibling of player in scene
	#GlobalPlayerManager.player.add_sibling(prop)
	GlobalPlayerManager.player.call_deferred("add_sibling",prop)
	#_current_scene.call_deferred("add_child",prop)

	wall_detect_collision_shape_2d.set_deferred("disabled", false)
	#wall_detect_character_body_2d.set_collision_mask_value(5, true)
	#if hurtbox
	if _hurt_box != null:
		#turn on hurtbox
		#_hurt_box.monitoring = true
		_hurt_box.set_deferred("monitoring",true)
		#connect signal from hurtbox to trigger destroy animation when dealing damage

	#turn on wall detection, connects signal to destroy when hitting a wall
	
	direction_when_thrown = GlobalPlayerManager.player.cardinal_direction
	prop.global_position = GlobalPlayerManager.player.held_item_marker_2d.global_position
	prop.global_position.y += 5
	#propel pot from position in direciton player is facing
	is_dropping = false
	is_thrown = true
	#set player.held_item to null
	#prop.sprite_2d.z_index = 1
	#wall_detect_collision_shape_2d.disabled = false
	#await _current_scene.process_frame
	GlobalPlayerManager.player.held_prop = null
	GlobalPlayerManager.player.held_prop_throwable = null
	#start the appropriate timer
	if direction_when_thrown == Vector2.UP or direction_when_thrown == Vector2.DOWN:
		up_down_drop_timer.start()
		print("updowntimerstarted")
	elif direction_when_thrown == Vector2.RIGHT or direction_when_thrown == Vector2.LEFT:
		drop_timer_1.start()
		print("timer1started")
	pass

func _drop_2()->void:
	is_dropping = true
	drop_timer_2.start()
	print("timer2started")

func _updown_drop()->void:
	destroy()

func hurtboxoff()->void:
	_hurt_box.monitoring = false
func hurtboxon()->void:
	_hurt_box.monitoring = true

func destroy()->void:
	_hurt_box.set_deferred("monitoring",false)
	#_hurt_box.monitoring = false
	is_destroyed = true
	print("DESTROY")
	#stop dropping on y axis
	is_dropping = false
	#stop drop timer
	drop_timer_1.stop()
	drop_timer_2.stop()
	up_down_drop_timer.stop()
	#disconnect drop signal
	#play destroy animation
	prop.animation_player.play("destroy")
	await prop.animation_player.animation_finished
	prop.queue_free()
	pass
	

	
func _wall_hit(_a)->void:
	print("wall got hit" + _a.name)
	destroy()

func player_interact()->void:
	#prevents picking up two
	if GlobalPlayerManager.player.held_prop !=null:
		return
	if picked_up == false:
		if prop.get_parent():
			prop.get_parent().remove_child(prop)
		prop.collision_shape_2d.disabled = true
		GlobalPlayerManager.player.held_item_marker_2d.add_child(prop)
		prop.global_transform = GlobalPlayerManager.player.held_item_marker_2d.global_transform
		#GlobalPlayerManager.player.pickup_item(self)
		area_entered.disconnect(_on_area_entered)
		area_exited.disconnect(_on_area_exited)
		GlobalPlayerManager.player.held_prop = prop
		GlobalPlayerManager.player.held_prop_throwable = self
		pass

func _on_area_entered(_area:Area2D)->void:
	GlobalPlayerManager.interact_pressed.connect(player_interact)
	
func _on_area_exited(_area:Area2D)->void:
	GlobalPlayerManager.interact_pressed.disconnect(player_interact)
	
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
	
