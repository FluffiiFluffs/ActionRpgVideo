@icon("res://ASSETS/Icons/cutscene_animation.svg")
class_name CutsceneActionAnimation
extends CutsceneAction

##Probably create this AnimationPlayer as a child of the root of the scene
@export var animation_player:AnimationPlayer
@export var animation_name:String

#inherited from CutscenAction
#signal started
#signal finished

func play()->void:
	if animation_player == null:
		printerr(str(name), " DOES NOT HAVE ANIMATION_PLAYER!")
		return
	if animation_name == "" or animation_name == null:
		printerr(str(name), " DOES NOT HAVE ANIMATION_NAME!")
		return
	if animation_player != null and animation_name != "" and animation_name != null:
		animation_player.process_mode = Node.PROCESS_MODE_ALWAYS
		animation_player.play( animation_name ) 
		await animation_player.animation_finished
		finished.emit()
	else:
		printerr(str(name), " FINISHED BUT DID NOT PLAY DUE TO NULL")
		finished.emit()
	pass
