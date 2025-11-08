##GLOBAL CLASS NotifyPanel
extends CanvasLayer


@onready var audio_stream_player = %AudioStreamPlayer
@onready var positioner = %NotifyPositioner
@onready var title_label = %TitleLabel
@onready var message_label = %MessageLabel

var up_position:Vector2=Vector2(0,-100)
var down_position:Vector2=Vector2.ZERO
var left_position:Vector2=Vector2(-300,0)
var shown_duration:float=2.0
var tween_time:float=0.25
var notifying:bool=false
var notify_queue : Array = []

signal notify_finished

func _ready()->void:
	prep_notifier() #moves positioner off the screen and modulate.a=0.0
	notify_finished.connect(notification_finished)

func queue_notification(_title:String, _message:String)->void:
	add_notification_to_queue(_title, _message)
	pass

func add_notification_to_queue(_title:String, _message:String)->void:
	notify_queue.append(
		{
			title = _title,
			message = _message,
			})
	if notifying == true:
		return
	if DialogSystem.is_active:
		return
	display_notification()
	pass
	
func notification_finished()->void:
	display_notification()

func display_notification()->void:
	var _n = notify_queue.pop_front()
	if _n == null:
		return
	title_label.text = _n.title
	message_label.text = _n.message
	notify_tween_down()
	pass


func notify_tween_down()->void:
	notifying = true
	var tween = create_tween()
	tween.set_parallel(true)
	positioner.position = up_position
	positioner.modulate.a = 0.0
	tween.tween_property(positioner,"modulate:a", 1.0, tween_time)
	tween.tween_property(positioner,"position", down_position, tween_time)
	play_toast()
	await tween.finished
	await get_tree().create_timer(shown_duration).timeout
	notify_tween_up()

func notify_tween_up()->void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(positioner,"position", left_position, tween_time)
	tween.tween_property(positioner,"modulate:a", 0.0, tween_time)
	await tween.finished
	await get_tree().create_timer(0.3).timeout
	notifying = false
	notify_finished.emit()
	
func play_toast()->void:
	audio_stream_player.stream = preload("uid://bmgaxb1jfa715")
	audio_stream_player.play()


func _unhandled_input(_event:InputEvent):
	if Input.is_action_just_pressed("test1"):
		pass
	
func prep_notifier()->void:
	positioner.position = up_position
	positioner.modulate.a = 0.0
