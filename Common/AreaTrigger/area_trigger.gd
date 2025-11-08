class_name AreaTrigger
extends Area2D

@onready var persistent_data_handler = %PersistentDataHandler

signal player_entered
var dialog : DialogInteraction
var triggered:bool=false #so this can only be triggered once


func _ready()->void:
	body_entered.connect(_on_body_entered)
	if persistent_data_handler.get_value() != null:
		triggered = persistent_data_handler.get_value() #determines on a load game if this has been triggered
	for child in get_children(): #finds the first DialogInteraction child under this node
		if child is DialogInteraction:
			dialog = child
			break #stops the loop once the first DialogInteraction is found

func _on_body_entered(_body:Player)->void:
	if triggered == true:
		return
	if dialog: 
		triggered = true
		dialog.player_interact()
	
	persistent_data_handler.set_value() #saves that this has been triggered before
	player_entered.emit()
	pass
