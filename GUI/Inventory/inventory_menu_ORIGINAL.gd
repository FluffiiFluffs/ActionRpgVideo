##THIS IS A GLOBAL SCRIPT
##class_name InventoryMenu[br]
extends CanvasLayer

##Scene for individual inventory slot
##This constant will be instantiated and configured with a script
const INVENTORY_SLOT = preload("uid://c421cipfkxiy4")

@onready var inventory_grid_container = %InventoryGridContainer

##Variable holds InventoryData (InventoryData.slots called later)
@export var data :InventoryData
@onready var description_label = %DescriptionLabel
@onready var audio_stream_player = %AudioStreamPlayer

##For tweening animation
@onready var inventory_positioner = %InventoryPositioner
var inventory_is_open : bool = false
var inventory_is_animating : bool = false
var inventory_starting_pos_y : int = -325
var inventory_final_pos_y : int = 0
##
const MENU_CLOSE = preload("uid://cr2cojusrxpdc")
const MENU_OPEN = preload("uid://dif2ho63xeg7b")

var focus_index: int = 0

signal inventory_open
signal inventory_closed



# Called when the node enters the scene tree for the first time.
func _ready():
	InventoryMenu.inventory_open.connect(update_inventory)
	InventoryMenu.inventory_closed.connect(clear_inventory)
	clear_inventory()
	data.changed.connect(_on_inventory_changed)
	_start_position()
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _unhandled_input(_event):
	#makes sure the pause menu isn't open or trying to open
	if PauseMenu.menu_is_open or PauseMenu.menu_is_animating:
		return
	elif DialogSystem.is_active == true:
		return
	elif  GlobalLevelManager.title_screen_active:
		return
	elif GameOverScreen.gameoverscreen_active == true:
		return
	elif !inventory_is_animating:
			if Input.is_action_just_pressed("inventory_input"):
				if inventory_is_open:
					close_inventory()
				elif !inventory_is_open:
					open_inventory()
				
##Gets rid of all children within inventory_grid_container
func clear_inventory() -> void:
	description_label.text = ""
	for child in inventory_grid_container.get_children():
		child.queue_free()
		
##Instantiates new button 
##Adds instance to grid container
##Assigns slot data to each
##Grabs focus of the first item slot so not-mouse can be used
func update_inventory() -> void:
	clear_inventory()
	for slot in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		inventory_grid_container.add_child(new_slot)
		#assigns slot data to button. 
		#Uses set function found in inventory_slot_UI.slot_data
		new_slot.slot_data = slot
		new_slot.button.focus_entered.connect(item_focused)
	
	if inventory_grid_container.get_children() == []:
		return
	#var grid_child = inventory_grid_container.get_child(focus_index)
	#if grid_child != null:
		#for child in grid_child.get_children():
			#if child is Button:
				#child.grab_focus()


			

##Sets focus_index scriptwide variable to an integer equal to slot in inventory[br]
##Finds focused element of the UI to variable[br]
##stores children of inventory_grid_container in variable _slots[br]
##iterates over _slots to find focused node[br]
##focus_index updated
func item_focused() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	#print(focused)
	if focused == null:
		return
	var _slots := inventory_grid_container.get_children()
	for i in _slots.size():
		var slot := _slots[i]
		if slot == focused or slot.is_ancestor_of(focused):
			focus_index = i
			return

##Clears inventory when an item quantity hits 0...important or the slots will double
##Updates inventory when an item hits 0 quantity
func _on_inventory_changed():
	clear_inventory()
	var i = focus_index
	var slots = inventory_grid_container.get_children()
	i = clampi(focus_index-1, 0, slots.size())
	update_inventory()
	await get_tree().process_frame
	var grid_child = inventory_grid_container.get_child(i)
	for c in grid_child.get_children():
		if c is Button:
			c.grab_focus()
	
##Sets item description
func update_item_description( new_text:String) -> void:
	description_label.text = new_text

func play_item_sound(item_sound:AudioStream) -> void:
	if item_sound != null:
		audio_stream_player.stream = item_sound
		audio_stream_player.play()
		

##Sets the start position of the inventory menu (hidden, up) [br]
func _start_position():
	inventory_positioner.global_position.y = inventory_starting_pos_y

##Fully handles opening and closing of the inventory in one function.[br]
##Swaps 	positions and bools define in scriptwide scope
func inventory_tween():
	if !inventory_is_open: #inventory is closed, prepares for open
		inventory_final_pos_y = 0
		inventory_is_open = true
		inventory_open.emit()
		get_tree().paused = true
	elif inventory_is_open: #inventory open, prepares for close
		inventory_final_pos_y = -325
		inventory_is_open = false
		inventory_closed.emit()
		get_tree().paused = false
	inventory_is_animating = true
	var tween = create_tween()
	tween.tween_property(inventory_positioner,
	"global_position:y", inventory_final_pos_y, 0.25)
	await tween.finished
	inventory_is_animating = false
	
func open_inventory():
	audio_stream_player.stream = MENU_OPEN
	audio_stream_player.play()
	inventory_tween()
	inventory_open.emit()
	#Places UI focus on the first item
	await get_tree().create_timer(0.1).timeout
	var focus_target = inventory_grid_container.get_children()
	for child in focus_target:
		for c in child.get_children():
			if c is Button:
				#print(c)
				c.grab_focus()
				return
func close_inventory():
	_clear_ui_focus()
	audio_stream_player.stream = MENU_CLOSE
	audio_stream_player.play()
	inventory_tween()
	inventory_closed.emit()


#func item_focused() -> void:
	#var inv_child_count = inventory_grid_container.get_child_count()
	#for i in inv_child_count:
		#var grid_child = inventory_grid_container.get_children()
			##if grid_child is InventorySlotUI:
				##var slot_child = grid_child.get_children()
				##for c in slot_child:
					##if c is Button and c.has_focus():
						###if c.has_focus():
						##focus_index = i
		#return
func _clear_ui_focus() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null:
		focused.release_focus()
