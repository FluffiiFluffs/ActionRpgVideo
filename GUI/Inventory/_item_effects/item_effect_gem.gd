class_name ItemEffectGem
extends ItemEffect


#@export var audio : AudioStream

func use() -> void:
	PlayerHUD.actual_gems += 1
