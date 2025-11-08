@tool
class_name TreasureChest
extends Node2D

@onready var is_open_persistence = %IsOpenPersistence
@onready var item_sprite = %ItemSprite
@onready var sprite_2d = %Sprite2D
@onready var label = %Label
@onready var player_detection_area_2d = %PlayerDetectionArea2D
@onready var animation_player = %AnimationPlayer

@export var item_data : ItemData : set = _set_item_data
@export var quantity : int=1 : set = _set_quantity

var is_open : bool = false

func _ready() -> void:
	_update_Label()
	_update_texture()
	if Engine.is_editor_hint():
		return
	player_detection_area_2d.area_entered.connect(_on_player_detected)
	player_detection_area_2d.area_exited.connect(_on_player_undetected)
	is_open_persistence.data_loaded.connect(_set_chest_state)
	_set_chest_state()
	
	
##Called by _ready()[br]
##current_save.persistence Array holds the bool value once this has been opened.[br]
##current_save.persistance.value is loaded during _ready() on scene load.
func _set_chest_state() -> void:
		is_open = is_open_persistence.value
		if is_open:
			animation_player.play("open")
		else:
			animation_player.play("closed")
			
	


func _set_item_data(value:ItemData) -> void: 
	item_data = value
	_update_texture()

func _set_quantity(value:int) -> void:
	quantity = value
	_update_Label()
	
func _update_texture() -> void:
	if item_data and item_sprite:
		item_sprite.texture = item_data.texture

func _update_Label() -> void:
	if label:
		if quantity <= 1:
			label.text = ""
		else:
			label.text = "x " + str(quantity)

func _on_player_detected(_area : Area2D):
		GlobalPlayerManager.interact_pressed.connect(_player_interacted)

func _on_player_undetected(_area : Area2D):
		GlobalPlayerManager.interact_pressed.disconnect(_player_interacted)

func _player_interacted():
	if is_open == true:
		return
	is_open = true
	is_open_persistence.set_value()
	animation_player.play("open_chest")
	#checks to make sure there is actually item data
	if item_data and quantity > 0:
		if item_data.use_on_pickup==false:
			GlobalPlayerManager.INVENTORY_DATA.add_item(item_data, quantity)
		elif item_data.use_on_pickup==true:
			for i in quantity:
				item_data.use()
				#await get_tree().process_frame	
	else:
		printerr("NO ITEM IN CHEST") # outputs in print
		push_error("NO ITEM IN CHEST CHEST|Name: ", name) #outputs in debugger
	await animation_player.animation_finished
	animation_player.play("open")
