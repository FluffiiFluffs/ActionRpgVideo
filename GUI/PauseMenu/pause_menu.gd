extends CanvasLayer
##TODO Add options menu
##TODO add volume controls
##TODO add shake toggle
##TODO add voice chatter toggle
##TODO Implement dev menu options


@onready var texture_rect: TextureRect = %TextureRect
@onready var color_rect: ColorRect = %ColorRect
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var pause_menu_root: CanvasLayer = $"."
@onready var blur_mat: ShaderMaterial = color_rect.material as ShaderMaterial
@onready var close_button :Button= %CloseButton
@onready var save_button :Button= %SaveButton
@onready var load_button :Button= %LoadButton
@onready var exit_game_button :Button= %ExitGameButton
@onready var h_separator_2 = %HSeparator2
@onready var h_separator_3 = %HSeparator3
@onready var main_menu_button = %MainMenuButton
@onready var voices_button = %VoicesButton
@onready var controls_margin_container = %ControlsMarginContainer
@onready var main_margin_container = %MainMarginContainer
@onready var controls_back = %ControlsBack
@onready var controls_button = %ControlsButton

const TITLE_SCENE = "uid://km766l0xtbmw"


var game_is_paused:bool = false
var menu_is_open :bool= false
var menu_is_animating :bool= false
var voices_enabled:bool=true

signal pause_menu_closed
signal pause_menu_opened

func _ready() -> void:

	exit_game_button.pressed.connect(_on_exit_game_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	voices_button.pressed.connect(_toggle_voices)
	controls_button.pressed.connect(_on_controls_button_pressed)
	controls_back.pressed.connect(_on_controls_back_pressed)
	
	main_margin_container.visible = true
	controls_margin_container.visible = false
	
	
	texture_rect.visible = false
	color_rect.visible = false
	visible = false
	

	texture_rect.modulate = Color(0, 0, 0, 0)
	if blur_mat:
		blur_mat.set_shader_parameter("blur_amount", 0.0)

func _toggle_voices()->void:
	if voices_enabled == true:
		voices_enabled = false
		voices_button.text = "VOICES OFF"
	else:
		voices_enabled = true
		voices_button.text = "VOICES ON"


func _unhandled_input(event: InputEvent) -> void:
	if !menu_is_animating:
		if GameOverScreen.gameoverscreen_active == true:
			return
		elif  GlobalLevelManager.title_screen_active:
			return
		elif ShopMenu.shop_open == true:
			return
		if event.is_action_pressed("pause_menu"):
			if not menu_is_open:
				pause_menu_open()
			else:
				pause_menu_close()
	
		if event.is_action_pressed("cancel_input"):
			if menu_is_open:
				pause_menu_close()
		
		get_viewport().set_input_as_handled()	
	else:
		return


##Pause Menu Open Function
func pause_menu_open() -> void:
	if GlobalSaveManager.get_save_file() == null:
		load_button.visible = false
		h_separator_3.visible = false
	else:
		load_button.visible = true
		h_separator_3.visible = true
	menu_is_open = true
	texture_rect.visible = true
	color_rect.visible = true
	_open_tween()
	main_margin_container.visible = true
	controls_margin_container.visible = false
	visible = true
	close_button.grab_focus()

##Pause Menu Close Function
func pause_menu_close() -> void:
	_close_tween()

##Tween function for displaying pause background elements
func _open_tween() -> void:
	#animation_player.play("defaultplay")
	get_tree().paused = true
	menu_is_animating = true
	texture_rect.modulate = Color(0, 0, 0, 0)
	if blur_mat:
		blur_mat.set_shader_parameter("blur_amount", 0.0)
	var tween := create_tween()
	#tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	#tween.set_ease(Tween.EASE_IN)
	#tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel()
	tween.tween_property(blur_mat, "shader_parameter/blur_amount", 1.0, 0.15)
	tween.tween_property(texture_rect, "modulate", Color(1, 1, 1, 0.1), 0.15)
	await tween.finished
	pause_menu_opened.emit()
	menu_is_animating = false


##Tween function for hiding pause menu elements
func _close_tween() -> void:
	menu_is_animating = true
	texture_rect.modulate = Color(1, 1, 1, 0.1)
	if blur_mat:
		blur_mat.set_shader_parameter("blur_amount", 1.0)
	var tween := create_tween()
	#tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	#tween.set_ease(Tween.EASE_IN)
	#tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel()
	tween.tween_property(blur_mat, "shader_parameter/blur_amount", 0.0, 0.15)
	tween.tween_property(texture_rect, "modulate", Color(1, 1, 1, 0.0), 0.15)
	await tween.finished
	#animation_player.stop()
	color_rect.visible = false
	texture_rect.visible = false
	menu_is_open = false
	menu_is_animating = false
	pause_menu_root.visible = false
	#if InventoryMenu.inventory_is_open:
		#return
	pause_menu_closed.emit()
	_clear_ui_focus()
	if DialogSystem.is_active == true:
		return
	if !InventoryMenu.inventory_is_open:
		get_tree().paused = false
	
func _on_save_button_pressed() -> void:
	if menu_is_open:
		GlobalSaveManager.save_game()
		pause_menu_close()
func _on_load_button_pressed() -> void:
	if menu_is_open:
		DialogSystem.hide_dialog()
		DialogSystem.text_in_progress = false
		DialogSystem.timer.stop()
		GlobalSaveManager.load_game()
		pause_menu_close()
		await GlobalLevelManager.level_load_started
func _on_close_button_pressed() -> void:
	_close_tween()
func _on_exit_game_button_pressed() -> void:
	get_tree().quit()
func _on_main_menu_pressed()->void:
	GlobalAudioManager.play_music(null)
	GlobalLevelManager.load_new_level(TITLE_SCENE,"LevelTransition",Vector2.ZERO)
	pause_menu_close()
func _clear_ui_focus() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null:
		focused.release_focus()
		
func _on_controls_button_pressed()->void:
	main_margin_container.visible = false
	controls_margin_container.visible = true
	controls_back.grab_focus()

func _on_controls_back_pressed()->void:
	main_margin_container.visible = true
	controls_margin_container.visible = false
	controls_button.grab_focus()
