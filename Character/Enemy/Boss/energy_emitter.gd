class_name EnergyEmitter
extends Node2D
@onready var area_2d = %Area2D
@onready var beam_timer = %BeamTimer

@onready var sprite_2d = %Sprite2D
@export var energy:PackedScene=preload("uid://c1mqi2fctyp5f")

var player_detected:bool=false

func _ready()->void:
	sprite_2d.queue_free()
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	beam_timer.timeout.connect(shoot_beam)
	GlobalLevelManager.level_load_completed.connect(level_loaded_stop)
	GlobalLevelManager.level_load_started.connect(level_loaded_stop)
	
func shoot_beam()->void:
	if GlobalPlayerManager.player.hp < 1:
		queue_free()
	if player_detected:
		if beam_timer.time_left == 0 or beam_timer.is_stopped():
			beam_timer.start()
			var beam = energy.instantiate()
			await get_tree().process_frame
			add_child(beam)
			beam.global_position = global_position

func _on_body_entered(_body:Player)->void:
	if _body is Player:
		player_detected=true
		if beam_timer.time_left == 0 or beam_timer.is_stopped():
			shoot_beam()
		
func _on_body_exited(_body:Player)->void:
	if _body is Player:
		beam_timer.stop()
		player_detected=false
		for child in get_children():
			if child is EnergyBeamSmall or child is EnergyOrb:
				if child.is_charging:
					child.queue_free()
				else:
					return

func level_loaded_stop()->void:
	beam_timer.stop()
	player_detected=false
	for child in get_children():
		if child is EnergyBeamSmall or child is EnergyOrb:
			if child.is_charging:
				child.audio_stream_player_2d.stop()
				child.queue_free()
			else:
				return
