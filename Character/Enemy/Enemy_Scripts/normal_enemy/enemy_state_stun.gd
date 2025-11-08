class_name EnemyStateStun extends EnemyState

@export var anim_name : String = "stun"
@export var knockback_speed : float = 200.0
@export var decelerate_speed : float = 10.0
@onready var ehurt_box = %HurtBox
@export var attack_hurtbox : HurtBox
@export_category("AI")
@export var next_state: EnemyState
@export var ifstunned_state: EnemyState

var _direction : Vector2
##Triggers next state
var _animation_finished : bool = false
var _damage_position : Vector2
var ability_stunned : bool = false
var weapon_stunned : bool = false
var ability_stunned_duration : float = 2.1
var stun_timer : Timer


##What happens when state is initialized
func init() -> void:	
	enemy.enemy_damaged.connect(_on_enemy_damaged)

func _ready() -> void:
	pass
	

func enter() -> void:
	if enemy.stun_timer != null:
		if !enemy.stun_timer.is_stopped():
			next_state = ifstunned_state
		elif enemy.stun_timer.is_stopped():
			next_state = next_state
		ehurt_box.monitoring = false
		if attack_hurtbox != null:
			attack_hurtbox.monitoring = false
		enemy.invulnerable = true
		_animation_finished = false
		_direction = enemy.global_position.direction_to(_damage_position)
		enemy.set_direction(_direction)
		enemy.velocity = _direction * -knockback_speed
		enemy.update_animation(anim_name)
		#await get_tree().process_frame
		#enemy.animation_player.animation_finished.connect(_on_animation_finished)
		#await enemy.animation_player.animation_finished
		#enemy.animation_player.animation_finished.disconnect(_on_animation_finished)
		await get_tree().create_timer(0.5).timeout
		_animation_finished = true
	return

## What happens when the state is exited
func exit() -> void:
	if attack_hurtbox != null:
		attack_hurtbox.monitoring = true
	if !enemy.is_stunned:		
		ehurt_box.monitoring = true
	enemy.invulnerable = false
	
	
## What happens during _process(): update while state is running
func process (delta : float) -> EnemyState:
	if _animation_finished == true:
		return next_state
	enemy.velocity -= enemy.velocity * decelerate_speed * delta	
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> EnemyState:
	return null	
#
#func _on_enemy_damaged(hurt_box) -> void:
	#if hurt_box is HurtBox:
		#_damage_position = hurt_box.global_position
		#state_machine.change_state(self)
func _on_enemy_damaged(hurt_box) -> void:
	# do not override ability stun
	if enemy.is_stunned:
		return
	if hurt_box is HurtBox:
		_damage_position = hurt_box.global_position
		state_machine.change_state(self)


	#
func _on_animation_finished(_a : String):
	_animation_finished = true
