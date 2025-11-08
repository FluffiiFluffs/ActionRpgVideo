##ALERT This is a global script!
##This needs to be loaded AFTER the PlayerHUD global
extends Node

const PLAYER = preload("uid://bn7i86xc85v7o")
const INVENTORY_DATA : InventoryData = preload("uid://bxbw6n6nxox4w")
@warning_ignore("unused_signal")
signal interact_pressed
signal camera_shook(trauma:float)

var player:Player
var player_spawned : bool = false
var is_moving: bool = false
var current_ability : AbilityState = AbilityState.BOOMERANG

enum AbilityState { BOOMERANG, BOMB, BOW, HOOKSHOT, NONE }

func _ready() -> void:
	process_mode = self.PROCESS_MODE_ALWAYS
	add_player_instance()
	await get_tree().create_timer(0.1).timeout
	player_spawned = true

##Adds player instance to scene.[br]
##player is a child of GlobalPlayerManager autoload[br]
##Must be used in conjuction with set_as_parent() to work correctly.[br]
##set_as_parent() should be used in a level scene's root node script.
func add_player_instance() -> void:
	player = PLAYER.instantiate()
	add_child(player)

func load_health(hp: int, max_hp: int) ->void:
	player.max_hp = max_hp
	player.hp = hp
	#updates UI
	player.update_hp(0)

##Places player node at a new position.
func set_player_position(_new_pos:Vector2) -> void:
	player.global_position = _new_pos
	
##Removes player node as a child from GlobalPlayerManager	and assigns
##the player to the node running this function
##(must use self to reparent the node to the node running this)
func set_as_parent(_parent : Node2D) -> void:
	if player.get_parent():
		player.get_parent().remove_child(player)
	_parent.add_child(player)

##Removes the player from the parent used as an argument (self)	
func unparent_player(_parent:Node2D) -> void:
	_parent.remove_child(player)	
	
func emit_interact_pressed()->void:
	interact_pressed.emit()
	
func shake_camera(trauma:float=1)->void:
	camera_shook.emit(trauma)
	
