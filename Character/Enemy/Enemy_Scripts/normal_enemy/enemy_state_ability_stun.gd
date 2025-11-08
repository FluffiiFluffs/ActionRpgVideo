class_name EnemyStateAbilityStun extends EnemyState

@export var anim_name : String = "stun"
@export var knockback_speed : float = 200.0
@export var decelerate_speed : float = 10.0
@onready var ehurt_box = %HurtBox
@export var attack_hurtbox : HurtBox 

@export_category("AI")
@export var next_state: EnemyState
@export var if_ability_stunned_state : EnemyState
@export var if_weapon_stunned_state : EnemyState
var _direction : Vector2
##Triggers next state
var _stun_finished : bool
var _damage_position : Vector2
#var weapon_stun_timer: Timer
#var ability_stun_timer:Timer
var stun_type : String = ""
var current_hurt_box

##What happens when state is initialized
func init() -> void:	
	enemy.enemy_damaged.connect(_on_enemy_damaged)

func _ready() -> void:
	pass

func _on_enemy_damaged(hurt_box) -> void:
	current_hurt_box = hurt_box
	if hurt_box is HurtBox:
		if enemy.is_ability_stunned: #does not enter state, since already in the state
			_damage_position = hurt_box.global_position
			next_state = if_weapon_stunned_state
			just_knockback()
		elif !enemy.is_ability_stunned: #enters stun state
			_stun_finished = false
			stun_type = "weapon"
			_damage_position = hurt_box.global_position
			await get_tree().process_frame
			create_weapon_stun_timer(0.275) #exits state after done
			state_machine.change_state(self)
	if hurt_box is StunHurtBox:
		#if state_machine.current_state is EnemyStateAbilityStun:
			#return
		if !enemy.can_be_stunned: #do nothing
			return
		elif enemy.is_ability_stunned: #do nothing
			return
		elif !enemy.is_ability_stunned: #enter stun state
			_stun_finished = false
			stun_type = "ability"
			_damage_position = hurt_box.global_position
			await get_tree().process_frame
			create_ability_stun_timer(5.0) #exits state after done
			state_machine.change_state(self)

func enter() -> void:
	if stun_type == "weapon":
		#await get_tree().process_frame
		normal_knockback()
	if stun_type == "ability":
		#await get_tree().process_frame
		ability_stunned()
		
func normal_knockback()->void:
	enemy.invulnerable = true
	ehurt_box.monitoring = false
	if attack_hurtbox != null:
		attack_hurtbox.monitoring = false
	just_knockback()
	#create_weapon_stun_timer(0.5) #exits state after done
	
func just_knockback()->void:
	enemy.animation_player.stop() #if this isn't here, the sound won't play on quick hits
	enemy.update_animation(anim_name)
	_direction = enemy.global_position.direction_to(_damage_position)
	enemy.set_direction(_direction)
	if current_hurt_box == null:
		return
	elif current_hurt_box.damage >1:
		enemy.velocity = _direction * -(knockback_speed*2.5)
	elif current_hurt_box.damage <= 1:
		enemy.velocity = _direction * -knockback_speed
	await enemy.animation_player.animation_finished

func ability_stunned()->void:
	ehurt_box.monitoring = false
	if attack_hurtbox != null:
		attack_hurtbox.monitoring = false
	enemy.invulnerable = false
	just_knockback()
	enemy.is_ability_stunned = true
	#create_ability_stun_timer(3.0) #exits state after done
	
# What happens during _process(): update while state is running
func process (delta : float) -> EnemyState:
	if _stun_finished == true:
		return next_state
	enemy.velocity -= enemy.velocity * decelerate_speed * delta	
	return null

## What happens when the state is exited
func exit() -> void:
	if attack_hurtbox != null:
		attack_hurtbox.monitoring = true
	ehurt_box.monitoring = true
	enemy.invulnerable = false

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> EnemyState:
	return null	
	
func create_weapon_stun_timer(time:float):
	var weapon_stun_timer = Timer.new()
	weapon_stun_timer.one_shot = true
	weapon_stun_timer.wait_time = time
	#print("WEAPON STUN " + str(enemy.name))
	await get_tree().process_frame
	add_child(weapon_stun_timer)
	weapon_stun_timer.timeout.connect(func _finished(): 
		if if_weapon_stunned_state != null:
			next_state = if_weapon_stunned_state
		#print("WEAPON STUN " + str(enemy.name))
		_stun_finished = true
		weapon_stun_timer.queue_free())
	weapon_stun_timer.start()

func create_ability_stun_timer(time:float):
	var ability_stun_timer = Timer.new()
	ability_stun_timer.one_shot = true
	ability_stun_timer.wait_time = time
	await get_tree().process_frame
	add_child(ability_stun_timer)
	#print("ABILITY STUN " + str(enemy.name))
	ability_stun_timer.timeout.connect(func _finished(): 
		if if_ability_stunned_state != null:
			next_state = if_ability_stunned_state
		#print("ABILITY STUN COMPLETED " + str(enemy.name))
		enemy.is_ability_stunned = false
		_stun_finished = true
		ability_stun_timer.queue_free())
	ability_stun_timer.start()
