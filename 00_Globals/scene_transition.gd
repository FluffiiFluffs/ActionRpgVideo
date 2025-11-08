extends CanvasLayer

@onready var animation_player = %AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


##Fade out function[br]
##True means that it's done
func fade_out() -> bool:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	return true

##Fade in function[br]
##True means that it's done
func fade_in() -> bool:
	animation_player.play("fade_in")
	await animation_player.animation_finished
	return true
