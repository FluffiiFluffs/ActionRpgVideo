class_name Area2DEndless
extends Area2D

@onready var marker_2d = %Marker2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	
func _on_body_entered(body:Player):

	GlobalPlayerManager.player.global_position.y = marker_2d.global_position.y
