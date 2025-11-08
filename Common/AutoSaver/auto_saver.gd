class_name AutoSaver
extends CanvasLayer

@onready var animation_player = %AnimationPlayer

func save_game()->void:
	animation_player.play("game_saved")
	GlobalSaveManager.save_game()
