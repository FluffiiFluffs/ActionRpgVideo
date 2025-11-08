class_name BossStateIdle extends BossState



@onready var teleport = %Teleport
@onready var attack_2 = %Attack2
@onready var big_attack = %BigAttack
@onready var attack_1 = %Attack1

@export var anim_name : String = "idle"

@export_category("AI")
@export var state_duration_min: float = 1.0
@export var state_duration_max : float = 1.35
@export var next_state: BossState


@export var random_states:Array[BossState]
const ORB = preload("uid://brk3000eta4nh")
@onready var timer_1 = %Timer1

var _timer : float = 0.0
var randtorch:int=0

##What happens when state is initialized
func init() -> void:
	pass

func _ready() -> void:
	timer_1.timeout.connect(torchfire)
	
## What happens when the state is entered
func enter() -> void:
	boss.invulnerable=true
	print("Boss in idle")
	boss.velocity = Vector2.ZERO
	_timer = randf_range(state_duration_min, state_duration_max)
	boss.animation_player.play("idle")
	if boss.hp < 15:
		timer_1.wait_time = 2
		timer_1.start()
	elif boss.hp < 11:
		timer_1.wait_time = 1.5
	elif boss.hp < 5:
		timer_1.wait_time = 1.25

	pass
## What happens when the state is exited
func exit() -> void:


	
	pass
	
	
## What happens during _process(): update while state is running
func process (_delta : float) -> BossState:
	var _playerloc :Vector2= GlobalPlayerManager.player.global_position
	var _dist_from_plr:float= boss.global_position.distance_to(_playerloc)
	if _dist_from_plr <= 50:
		print("BOSS WILL TELEPORT")
		boss_state_machine.change_state(teleport)
		return
	if boss.hp <= 10:
		next_state = big_attack
	elif boss.hp <= 15:
		next_state = attack_2
	elif boss.hp >= 16:
		next_state = attack_1
	_timer -= _delta
	if _timer <= 0:
		return next_state
	return null

## What happens during _physics_process(): update state is running
func physics( _delta: float) -> BossState:
	return null	


func torchfire()->void:
	random_torch()
	fire_orb(randtorch)
	if boss.hp < 10:
		torch_off(randtorch)



func random_torch()->void:
	randtorch = randi_range(0,boss.torches.size()-1)


func fire_orb(_value)->void:
	var orb = ORB.instantiate()
	boss.torches[randtorch].add_child(orb)
	orb.global_position = boss.torches[randtorch].global_position
	
func torch_off(_value:int)->void:
	#var random_torch:int=randi_range(0,boss.torches.size()-1)
	boss.torches[_value].is_lit = false
	
