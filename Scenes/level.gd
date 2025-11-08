##This should be attached to the root node of a level scenedsad
class_name Level
extends Node2D

@export var music : AudioStream

##ALERT USES GlobalPlayerManager[br]
##ALERT USES GlobalLevelManager[br]
##Enables Y-Sorting on the level scene this is attached to[br]
##Takes player node and makes it a child of the level node[br]
##(instead of GlobalPlayerManager)[br]
##Connects GlobalLevelManager's level_load_started signal to _free_level function[br]
##free level function removes player as a child of this node and then deletes this node[br]s
func _ready():
	GlobalLevelManager.title_screen_active = false
	PlayerHUD.visible = true
	self.y_sort_enabled = true
	GlobalPlayerManager.set_as_parent(self)
	GlobalLevelManager.level_load_started.connect(_free_level)
	#keeps music playing if there is no music set in the scene.
	if music == null:
		return
	else:
		GlobalAudioManager.play_music(music)
	
	
##ALERT USES GLOBAL PLAYER MANAGER[br]s
##GlobalPlayerManager calls unparent_player on self
func _free_level() -> void:
	GlobalPlayerManager.unparent_player(self)
	queue_free()
