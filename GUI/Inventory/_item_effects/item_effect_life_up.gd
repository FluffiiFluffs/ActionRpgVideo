class_name ItemEffectLifeUp
extends ItemEffect

@export var heal_amount : int = 2
@export var audio : AudioStream

func use() -> void:
	GlobalPlayerManager.player.max_hp = clampi(GlobalPlayerManager.player.max_hp+ 2, 6, 40)
	GlobalPlayerManager.player.update_max_hp_hud(GlobalPlayerManager.player.max_hp)
	GlobalPlayerManager.player.update_hp(99)
