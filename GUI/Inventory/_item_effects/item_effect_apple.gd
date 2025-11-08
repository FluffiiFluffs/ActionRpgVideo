class_name ItemEffectApple
extends ItemEffect

@export var heal_amount : int = 2
@export var audio : AudioStream

var cannot_use = false

func use() -> void:
	#set_cannot_use()
	#if cannot_use == false:
		#return
	#else:
	GlobalPlayerManager.player.update_hp(heal_amount)
	InventoryMenu.play_item_sound(audio)
	return

func set_cannot_use()->void:
	if GlobalPlayerManager.player.hp == GlobalPlayerManager.player.max_hp:
		cannot_use = true
	elif GlobalPlayerManager.player.hp != GlobalPlayerManager.player.max_hp:
		cannot_use = false
