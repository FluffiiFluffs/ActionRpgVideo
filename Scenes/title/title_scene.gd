class_name TitleScene
extends Node2D

const START_LEVEL: String = "uid://de34kxyl1ndmm"
const LEVEL_01_TEST : String = "uid://irxs5l32gb6f"


@onready var newgame_button:Button = %NEWGAMEButton
@onready var continue_button:Button = %CONTINUEButton
@onready var audio_stream_player:AudioStreamPlayer = %AudioStreamPlayer
@onready var secret_button = %SecretButton


func _ready()->void:
	secret_button.pressed.connect(_load_test_level)
	newgame_button.pressed.connect(_begin_new_game)
	continue_button.pressed.connect(_continue_game)
	GlobalLevelManager.level_load_started.connect(_exit_title_screen)
	if GlobalSaveManager.get_save_file() == null:
		continue_button.pressed.disconnect(_continue_game)
		continue_button.queue_free()
	setup_title_screen()

func setup_title_screen()->void:
	get_tree().paused = true
	GlobalLevelManager.title_screen_active = true
	GlobalPlayerManager.player.visible = false
	PlayerHUD.visible = false
	GlobalLevelManager.title_screen_active = true

func focus_newgame_button()->void:
	newgame_button.grab_focus()


func _exit_title_screen()->void:
	GlobalPlayerManager.player.visible = true
	audio_stream_player.stop()
	GlobalLevelManager.title_screen_active = false
	self.queue_free()
	
func _begin_new_game()->void:
	get_tree().paused = false
	GlobalPlayerManager.player.update_hp(99)
	reset_inventory()
	reset_persists()
	GlobalLevelManager.load_new_level(START_LEVEL,"LevelTransition3",Vector2.ZERO)
	#GlobalLevelManager.load_new_level(START_LEVEL,"",Vector2.ZERO)	
	#GlobalPlayerManager.set_player_position( Vector2(80,160) )
	GlobalLevelManager.title_screen_active = false
func _continue_game()->void:
	GlobalSaveManager.load_game()
	await GlobalLevelManager.level_load_started
	_exit_title_screen()
	
func _load_test_level()->void:
	$CanvasLayer/Control/VBoxContainer/RichTextLabel.text = "[wave]SECRET[/wave]"
	get_tree().paused = false
	GlobalPlayerManager.player.update_hp(99)
	reset_inventory()
	reset_persists()
	await get_tree().create_timer(0.5).timeout
	GlobalLevelManager.load_new_level(LEVEL_01_TEST,"LevelTransition",Vector2.ZERO)
	GlobalLevelManager.title_screen_active = false
	

func reset_inventory()->void:
	for slot in InventoryMenu.data.slots:
		if slot:
			slot.quantity = 0
	PlayerHUD.actual_gems = 0
	PlayerHUD.gems = 0
	PlayerHUD._set_gems_ui_quiet()
	
func reset_persists()->void:
	GlobalSaveManager.current_save.persistence = []
	GlobalSaveManager.current_save.quests = []
	GlobalQuestManager.current_quests = []
	GlobalSaveManager.current_save.player.max_hp = 6
	GlobalSaveManager.current_save.player.hp = 6
	GlobalPlayerManager.player.max_hp = 6
	GlobalPlayerManager.player.hp = 6
	GlobalPlayerManager.player.update_hp(6)
	PlayerHUD.update_max_hp(6)
	
