class_name Enemy extends CharacterBody2D

@onready var sprite :Sprite2D= %Sprite2D
@onready var animation_player:AnimationPlayer = %AnimationPlayer
@onready var hit_box :HitBox= %HitBox
@onready var enemy_state_machine :EnemyStateMachine= %EnemyStateMachine
@onready var hurt_box:HurtBox = %HurtBox
@export var can_be_stunned : bool = true
@export var hp: int = 3
var is_ability_stunned : bool = false

const DIR_4 : Array = [ Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP ]

signal direction_changed (new_direction:Vector2)
signal enemy_damaged(hurt_box)
signal enemy_destroyed(hurt_box)

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var player:Player
var invulnerable : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_state_machine.initialize(self)
	player = GlobalPlayerManager.player
	hit_box.damaged.connect(_take_damage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_ability_stunned or !can_be_stunned:
		await get_tree().process_frame
		set_collision_layer_value(9, false)
		set_collision_layer_value(10, true)
	elif !is_ability_stunned:
		await get_tree().process_frame
		set_collision_layer_value(9, true)
		set_collision_layer_value(10, false)

func _physics_process(_delta):
	move_and_slide()

func set_direction( new_direction : Vector2 ) -> bool:
	direction = new_direction
	if direction == Vector2.ZERO:
		return false
	
	var direction_id : int = int( round(
			( direction + cardinal_direction * 0.1 ).angle()
			/ TAU * DIR_4.size()
	))
	var new_dir = DIR_4[ direction_id ]
	
	if new_dir == cardinal_direction:
		return false
	
	cardinal_direction = new_dir
	direction_changed.emit( new_dir )
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	return true	
	
	
func update_animation(state : String) -> void:
	animation_player.play( state + "_" + anim_direction())
	#print(state,"_",anim_direction())

func anim_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "right"
		
func _take_damage(_hurt_box) -> void:
	if invulnerable == true:
		return
	hp -= _hurt_box.damage
	if hp > 0:
		enemy_damaged.emit(_hurt_box)
	else:
		enemy_destroyed.emit(_hurt_box)
