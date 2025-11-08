class_name NPCTerra
extends Node2D
@onready var animation_player = %AnimationPlayer
@onready var greet_area_2d = %GreetArea2D



@export var shop_data:ShopData
var player_greeted:bool=false


func _ready()->void:
	idle_loop()
	greet_area_2d.body_entered.connect(_play_wave)
	
	


func _play_wave(_body)->void:
	if _body is Player:
		if player_greeted == false:
			animation_player.stop()
			player_greeted = true
			animation_player.play("wave_down")
			await animation_player.animation_finished
			idle_loop()
			greet_area_2d.body_entered.disconnect(_play_wave)

	
func idle_loop()->void:
	animation_player.stop()
	var idle_time:float=randf_range(5.0, 10.0)
	#var idle_time = 1.0
	animation_player.play("idle_down_1")
	await get_tree().create_timer(idle_time, false).timeout
	animation_player.stop()
	animation_player.play("blink_down")
	await animation_player.animation_finished
	idle_loop()
	
func open_shop()->void:
	ShopMenu.shop_data = shop_data
	ShopMenu.show_menu()
