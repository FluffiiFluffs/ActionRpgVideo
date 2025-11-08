extends Sprite2D
@onready var animation_player = %AnimationPlayer

func _ready()->void:
	await get_tree().create_timer(0.375).timeout
	#await animation_player.animation_finished
	queue_free()
