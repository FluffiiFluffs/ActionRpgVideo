class_name StunHurtBox extends Area2D

@export var damage : int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	area_entered.connect( on_area_entered )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func on_area_entered(area : Area2D):
	if area is HitBox:
		area.TakeDamage( self )
		
