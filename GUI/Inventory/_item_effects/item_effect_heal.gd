class_name ItemEffectHeal
extends ItemEffect

@export var heal_amount : int = 2
@export var audio : AudioStream

#var cannot_use = false

func use() -> void:
	#if GlobalPlayerManager.player.hp == GlobalPlayerManager.player.max_hp:
		#cannot_use = true
	#else:
		#cannot_use = false
	GlobalPlayerManager.player.update_hp(heal_amount)
	InventoryMenu.play_item_sound(audio)
	return
