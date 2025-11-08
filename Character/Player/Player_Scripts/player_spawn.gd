extends Node2D
#Uses global position of player_spawn.tscn to instantiate player
#Uses global script GlobalPlayerManager

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	if GlobalPlayerManager.player_spawned == false:
		GlobalPlayerManager.set_player_position(global_position)
		GlobalPlayerManager.player_spawned = true
