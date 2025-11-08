extends Node2D

@onready var fog_timer = %FogTimer
@onready var dungeon_fog_overlay = %DungeonFogOverlay
@onready var sprite_2d = %Sprite2D

@export var autoscroll_x : float = clampf(10,5,25)
var scroll_direction : bool = true

func _ready() -> void:
	sprite_2d.visible = true
	fog_timer.timeout.connect(_on_fog_timer_timeout)
	dungeon_fog_overlay.autoscroll.x = autoscroll_x
	
func _on_fog_timer_timeout():
	if scroll_direction:
		dungeon_fog_overlay.autoscroll.x = autoscroll_x
		scroll_direction = false
	if !scroll_direction:
		dungeon_fog_overlay.autoscroll.x = -autoscroll_x
		scroll_direction = true
