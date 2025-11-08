## [b]PersistentDataHandler[/b]
## Keeps a single on or off state saved for a scene so it can be restored later. [br]
## Ideal for simple switches like an opened chest or a visited flag. [br][br]
## [b]Use[/b][br]
## Place [code]persistent_data_handler.tscn[/code] in the scene that owns the state you want to remember. [br]
## Rename the instance to clearly describe the state it persists for easier debugging and to avoid name collisions. [br]
## Example: "IsOpenPersistence" for a chest that should remember whether it was opened. [br][br]
## [b]Data scope[/b][br]
## Stores exactly one boolean value. [br][br]
## [b]Timing and performance[/b][br]
## The first read happens on scene ready and can be delayed during a scene change. [br]
## To avoid delay set the parent scene to [code]PROCESS_MODE_ALWAYS[/code] during the transition. [br]
## After the transition you may set the parent back to [code]PROCESS_MODE_INHERIT[/code]. [br]
class_name PersistentDataHandler
extends Node


##Signal is listened to by the scene/node it is attached to.[br]
##Signal used to set bools within the scene/node[br][br]
##EXAMPLE: See class [code]TreasureChest[/code]/_set_chest_state() and var is_open interactions.
signal data_loaded()


##Variable used to track true/false.[br]
##This is tracked by GlobalSaveManager.current_save.persistence once set_value() is called.[br]
##set_value() is called by the parent node's script this node is attached to.[br]
##EXAMPLE: See [code]TreasureChest[/code]/_player_interacted()
var value : bool = false

##Immediately calls get_value() on scene load.[br]
##get_value() finds if the persistent value exists within GlobalSaveManager.current_save.persistence[br]
##Signal data_loaded is emitted, and listened to by the scene's script this node is attached to.[br]
##EXAMPLE: see [code]TreasureChest[/code]/ _ready() and _set_chest_state()
func _ready() -> void:
	get_value()
	
##Places the scene_path/root_node_name/node_name into GlobalSaveManager.current_save.persistence Array
func set_value() -> void:
	GlobalSaveManager.add_persistent_value(_get_name())

##Retrieves scene_path/parent_node_name/node_name from GlobalSaveManager.current_save.persistence Array[br]
##emits Signal data_loaded, which should be listened to by the scene's script this node is attached to.
func get_value() -> void:
	value = GlobalSaveManager.check_persistent_value(_get_name())
	data_loaded.emit()
	
##Returns the scene file path, root level node, and this node's name.[br]
##example: res://Scenes/Level01/Level01_01.tscn/TreasureChest/IsOpen
func _get_name() -> String:
	var scene_path = get_tree().current_scene.scene_file_path #file path of the scene this is attached to
	var root_node_name = get_parent().name #name of the node this one is attached to
	var node_name = name #name of this node
	return str(scene_path) + "/" + str(root_node_name) + "/" + str(node_name)
	
func remove_value()->void:
	GlobalSaveManager.remove_persistent_value(_get_name())
	
