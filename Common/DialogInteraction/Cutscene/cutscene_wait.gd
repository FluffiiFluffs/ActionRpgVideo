@tool
@icon ("uid://dwo3npik7p1ir")
class_name CutsceneWait
extends CutsceneAction

#signals inherited from extended script
#signal started
#signal finished

##How long to wait
@export var wait_time:float=1.0


##Inherited from CutsceneAction
func play()->void:
	await get_tree().create_timer(wait_time, true).timeout
	finished.emit() #signal inherited from CutscneAction
	pass
