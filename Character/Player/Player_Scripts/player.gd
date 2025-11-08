class_name Player extends CharacterBody2D

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO

@onready var held_item_marker_2d = %HeldItemMarker2D
@onready var lift = %Lift
@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var sprite: Sprite2D = %Sprite2D
@onready var state_machine : PlayerStateMachine = %StateMachine
@onready var hit_box :HitBox= %HitBox
@onready var effect_animation_player :AnimationPlayer= %EffectAnimationPlayer
@onready var attack_sprite_2d = %AttackSprite2D
@onready var hurt_box = %HurtBox
@onready var interaction_animation_player = %InteractionAnimationPlayer
@onready var interaction_bubble_sprite_2d = %InteractionBubbleSprite2D
@onready var idle = %Idle
@onready var audio_stream_player_2d = %AudioStreamPlayer2D



const DIR_4 : Array = [ Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP ]

signal direction_changed( new_direction )
signal player_damaged(hurt_box:HurtBox)

var invulnerable : bool = false
var hp : int = 6
var max_hp : int = 6
var held_prop=null
var held_prop_throwable

func update_max_hp_hud(value:int)->void:
	PlayerHUD.update_max_hp(value)

func _ready() -> void:
	GlobalPlayerManager.player = self
	state_machine.initialize(self)
	hit_box.damaged.connect(_on_player_damaged)
	update_hp(hp)
	GlobalLevelManager.level_load_completed.connect(_on_load_completed)
	
	
func _process(_delta) -> void:
	#direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	direction = Vector2( Input.get_axis("move_left",
	"move_right"), Input.get_axis("move_up","move_down")).normalized()
	
func _physics_process(_delta):
	move_and_slide()

func set_direction() -> bool:
	if direction == Vector2.ZERO:
		return false

	var direction_id : int = int( round( ( direction + cardinal_direction * 0.1 ).angle() / TAU * DIR_4.size() ) )
	var new_dir = DIR_4 [ direction_id ]
		
	if new_dir == cardinal_direction:
		return false
		
	cardinal_direction = new_dir
	direction_changed.emit( new_dir )
	#sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	
	return true
	

func update_animation(state : String) -> void:
	animation_player.play( state + "_" + AnimDirection())

func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "right"

func _on_player_damaged(_hurt_box:HurtBox) -> void:
	if invulnerable == true:
		return
	if hp > 0:
		update_hp(-_hurt_box.damage)
		player_damaged.emit(_hurt_box)
		print("PLAYER HP: ", hp)
	else:
		player_damaged.emit(_hurt_box)
		#ALERT FOR TESTING
		#update_hp(99)
	
func update_hp(delta: int) -> void:
	hp = clampi(hp + delta, 0, max_hp)
	PlayerHUD.update_hp(hp, max_hp)
	
func make_invulnerable(_duration : float = 1.0) -> void:
	invulnerable = true
	call_deferred("hit_box_off")
	await get_tree().create_timer(_duration).timeout
	invulnerable = false
	call_deferred("hit_box_on")
	
func hit_box_on():
	hit_box.monitorable = true
	
func hit_box_off():
	hit_box.monitorable = false
	
	
func pickup_item(_item:Throwable)->void:
	state_machine.change_state(lift)


func _unhandled_input(_event):
	if Input.is_action_just_pressed("test1"):
		#update_hp(-99)
		#player_damaged.emit(%ChargeHurtBox)
		#GlobalPlayerManager.shake_camera()
		pass
		
func _on_load_completed()->void:
	#animation_player.play("RESET")
	animation_player.stop()
	state_machine.change_state(idle)
