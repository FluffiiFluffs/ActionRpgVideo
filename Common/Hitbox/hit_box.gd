class_name HitBox extends Area2D



signal damaged(hurt_box)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func TakeDamage( hurt_box ) -> void:
	#var node_name = hurt_box.get_parent().name
	#print(str(node_name) + " DAMAGED " + str(hurt_box.damage))
	if hurt_box is HurtBox or hurt_box is StunHurtBox:
		damaged.emit(hurt_box)
