extends Sprite2D
@onready var animation_player = %AnimationPlayer

func _ready()->void:
	await get_tree().create_timer(0.375).timeout
	queue_free()
