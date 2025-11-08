class_name InventorySlotUI
extends PanelContainer

@onready var button = %Button
@onready var texture_rect = %TextureRect
@onready var label = %Label


##Keeps track of slot data assigned to it (resource)
##calls set_slot_data any time a value within slot_data is changed
var slot_data : SlotData: set = set_slot_data

# Called when the node enters the scene tree for the first time.
func _ready():
	texture_rect.texture = null
	label.text = ""
	button.focus_entered.connect(_on_item_focus_focused)
	button.focus_exited.connect(_on_item_focus_exited)
	button.pressed.connect(_on_item_button_pressed)
	
func _on_item_button_pressed() -> void:
	if slot_data:
		if slot_data.item_data:
			#checks to see if the item_effect can be used, set in the actual script.
			#this is here to make sure that apples can't be used at full HP
			
			for effect in slot_data.item_data.effects:
				if effect is ItemEffectApple:
					if GlobalPlayerManager.player.hp == GlobalPlayerManager.player.max_hp:
						#slot_data.quantity += 1
						print("apple not used")
						return
				#elif effect.cannot_use == false:
					#var was_used = slot_data.item_data.use()
					#if !was_used:
						#return
					#slot_data.quantity -= 1
					elif GlobalPlayerManager.player.hp < GlobalPlayerManager.player.max_hp:
						#var was_used = slot_data.item_data.use()
						slot_data.item_data.use()
						#if !was_used:
							#return
						slot_data.quantity -= 1
			label.text = str(slot_data.quantity)


func set_slot_data(data:SlotData) -> void:
	slot_data = data
	if slot_data == null:
		return
	texture_rect.texture = slot_data.item_data.texture
	label.text = str(slot_data.quantity)
	
func _on_item_focus_focused():
	if slot_data != null: #protects against null error!!
		if slot_data.item_data != null: #protects against null error!!
			InventoryMenu.update_item_description(slot_data.item_data.description)
		
func _on_item_focus_exited():
	InventoryMenu.update_item_description("")
