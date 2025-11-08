#GlobalGameOverScreen

extends CanvasLayer
@onready var color_rect = %ColorRect
@onready var animation_player = %AnimationPlayer
@onready var continue_button = %ContinueButton
@onready var main_menu_button = %MainMenuButton
@onready var quit_button = %QuitButton
@onready var sprite_2d = %Sprite2D
@onready var v_box_container = %VBoxContainer

var gameoverscreen_active:bool=false
const LTTP_FILE_SELECT = preload("uid://baorj5d1bs8ey")
const TITLE_SCENE = "uid://km766l0xtbmw"


func _ready()->void:
	visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func play_circle_black():
	if GlobalSaveManager.get_save_file() == null:
		continue_button.visible = false
	gameoverscreen_active = true
	animation_player.play("death_circle")
	visible = true # needs to be after the animation starts or there is a weird flash after dying
	await animation_player.animation_finished
	GlobalAudioManager.play_music(LTTP_FILE_SELECT)
	if GlobalSaveManager.get_save_file() == null:
		main_menu_button.grab_focus()
	elif GlobalSaveManager.get_save_file() != null:
		continue_button.visible = true
		continue_button.grab_focus()

func unload_scene()->void:
	for child in get_tree().current_scene.get_children():
		if child is Level:
			child.queue_free()

func _on_continue_pressed()->void:
	#load last save
	DialogSystem.hide_dialog()
	DialogSystem.text_in_progress = false
	DialogSystem.timer.stop()
	animation_player.play("just_black")
	GlobalSaveManager.load_game()
	#GlobalAudioManager.play_music(null)
	await GlobalLevelManager.level_load_started
	await get_tree().create_timer(0.1).timeout
	gameoverscreen_active=false
	visible = false
	pass
func _on_main_menu_pressed()->void:
	#open main menu
	animation_player.play("just_black")
	GlobalAudioManager.play_music(null)
	GlobalLevelManager.load_new_level(TITLE_SCENE,"LevelTransition",Vector2.ZERO)
	await get_tree().create_timer(0.2).timeout
	gameoverscreen_active=false
	visible = false
	
	pass
func _on_quit_pressed()->void:
	get_tree().quit()
	pass
	
