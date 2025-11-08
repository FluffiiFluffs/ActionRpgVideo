class_name HurtBox extends Area2D

@export var damage : int = 1

signal hurt_something
signal touched_something
# Called when the node enters the scene tree for the first time.
func _ready():
	area_entered.connect( on_area_entered )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func on_area_entered(area : Area2D):
	if area is HitBox:
		area.TakeDamage( self )
		#used during player's spin attack charge up to determine if the player needs to exit the state
		hurt_something.emit(area)
		#used for throwables
		touched_something.emit()
