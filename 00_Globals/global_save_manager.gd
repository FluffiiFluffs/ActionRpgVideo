##This is a global script![br]
##This script is responsible for saving the game, loading the game and gathering data.
extends Node

const SAVE_PATH = "user://"

signal game_loaded
signal game_saved
var is_loading:bool=false
##Dictionary of things needed to be saved
var current_save : Dictionary = {
	"scene_path" = "",
	#player data
	"player" = {
		"hp" = 1,
		"max_hp" = 1,
		"pos_x" = 0,
		"pos_y" = 0,
		},
		"items" = [],
		"persistence" = [],
		"quests" = [ #{title="NOT FOUND", is_complete=false, completed_steps=[""]
			
		],
		"gems" = 0,
		"voices" = true, 
	}

##Function used to save the game[br]
func save_game() -> void: 
	update_player_data()
	update_scene_path()
	update_item_data()
	update_quest_data()
	update_gem_count()
	update_voices_enabled()
	#Opens (or creates) a file at the save path
	var file := FileAccess.open(SAVE_PATH + "save.sav", FileAccess.WRITE)
	#Converts variable current_save to JSON string
	var save_json =  JSON.stringify(current_save)
	#Stores string from save_json into file
	file.store_line(save_json)
	#emits game_saved signal (so other parts of the game can know)
	game_saved.emit()
	print("SAVE GAME FUNCTION")

func get_save_file()-> FileAccess:
	return FileAccess.open(SAVE_PATH + "save.sav", FileAccess.READ)


##UTILIZES LEVEL MANAGER AND PLAYER MANAGER GLOBALS
func load_game() -> void:
	#Accesses save file to be loaded (previously defined in save_game())
	var file := get_save_file()
	#Creates new JSON string, stored in a variable.
	var json := JSON.new()
	#Parses JSON file
	json.parse(file.get_line())
	#Stores parsed data into a dictionary
	var save_dict : Dictionary = json.get_data() as Dictionary
	current_save = save_dict
	#Loads scene from parsed file
	GlobalLevelManager.load_new_level(current_save.scene_path, "", Vector2.ZERO)
	#waits for the level to load
	is_loading=true
	await GlobalLevelManager.level_load_started
	
	
	GlobalPlayerManager.set_player_position(Vector2(current_save.player.pos_x, current_save.player.pos_y))
	GlobalPlayerManager.load_health(current_save.player.hp, current_save.player.max_hp)
	GlobalPlayerManager.INVENTORY_DATA.parse_save_data(current_save.items)
	GlobalQuestManager.current_quests = current_save.quests
	PlayerHUD.actual_gems = current_save.gems
	PlayerHUD.gems = current_save.gems
	PlayerHUD._set_gems_ui_quiet()
	PauseMenu.voices_enabled = current_save.voices
	
	await GlobalLevelManager.level_load_completed
	is_loading=false
	game_loaded.emit()
	
	
	print("LOAD GAME FUNCTION")
	

##Updates updates var current_save (Dictionary) with the player's data.[br]
##This data goes into current_save.player{} (Dictionary within current_save)
func update_player_data() -> void:
	var _player = GlobalPlayerManager.player
	current_save.player.hp = _player.hp
	current_save.player.max_hp = _player.max_hp
	current_save.player.pos_x = _player.global_position.x
	current_save.player.pos_y = _player.global_position.y

##Updates the "scene_path" string within var current_save.[br]
##This function saves the file path of the current scene being played.	
func update_scene_path() -> void:
	var _player: String = ""
	#looks for level. 
	for child in get_tree().root.get_children():
		if child is Level:
			_player = child.scene_file_path
	current_save.scene_path = _player

##fills current_save.items[] with INVENTORY_DATA array.
func update_item_data() -> void:
	current_save.items = GlobalPlayerManager.INVENTORY_DATA.get_save_data()

##Adds persistent value String to current_save.persistence Array within Dictionary "current_save"[br]
##variable current_save is a Dictionary defined in [b]THIS[/b] global script[br]
##current_save.persistence is saved in JSON format during the save_game() function.
func add_persistent_value( value : String) -> void:
	#value is saved only if it does not exist already.
	if check_persistent_value(value) == false:
		current_save.persistence.append(value)

##Erases the value provided from current_save array
func remove_persistent_value(value:String)->void:
	var p = current_save.persistence as Array
	p.erase(value)

##Returns bool. Checks if the value passed through this function is present within current_save.persistence Array[br]
##variable current_save is a Dictionary defined in [b]THIS[/b] global script
func check_persistent_value( value : String ) -> bool:
		#gets reference to persistence array (in this script)
	var _persist = current_save.persistence as Array
	#checks if the array contains value (passed through this function)
	#returns true or false
	return _persist.has(value)
	
func update_quest_data()->void:
	current_save.quests = GlobalQuestManager.current_quests

func update_gem_count()->void:
	current_save.gems = PlayerHUD.actual_gems

func update_voices_enabled()->void:
	current_save.voices = PauseMenu.voices_enabled
