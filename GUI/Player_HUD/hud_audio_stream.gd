class_name HUDAudioStream
extends AudioStreamPlayer
@onready var hud_audio_stream_2 = %HudAudioStream2

const WALLET_1 = preload("uid://ek4snl2epebd")
const WALLET_2 = preload("uid://dg7otxu2yy4dt")
const MIN_PLAY_TIME := 0.175 # seconds

func _ready()->void:
	PlayerHUD.gems_changed.connect(play_gem_sound)
	stream = WALLET_1
	hud_audio_stream_2.stream = WALLET_2
			
func play_gem_sound()->void:
	if !playing:
		play()
		hud_audio_stream_2.play()
		return
	if get_playback_position() >= MIN_PLAY_TIME:
		play()
	if hud_audio_stream_2.get_playback_position() >= MIN_PLAY_TIME:
			hud_audio_stream_2.play()
