class_name NPCResource
extends Resource

@export var npc_name : String = ""
@export var sprite_texture : Texture
@export var sprite_hframes : int
@export var sprite_vframes : int
##Normal expression
@export var portrait : Texture
##Mouth Open
@export var portrait_talk: Texture
##Smile
@export var portrait_special: Texture
@export var dialog_voice : AudioStream
@export_range(0.5, 1.5, 0.02) var dialog_audio_pitch : float = 1.0
