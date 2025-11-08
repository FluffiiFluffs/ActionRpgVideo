##Script that defines item resource properties
class_name ItemData
extends Resource
##Name of the item
@export var name : String = ""
##Description of the item in inventory screen
@export_multiline var description: String = ""
##What the shopkeeper says about this item
@export_multiline var shop_description:String = ""

##Texture file of the item
@export var texture : Texture
@export_category("Item Use Effects")
@export var effects: Array[ItemEffect]
##Sound effect when used
@export var sound_effect : AudioStream
##Toggle on to use immediately when being picked up, item does not go in inventory
@export var use_on_pickup:bool=false
##Sets the price in the shop
@export var shop_price:int=0


func use() -> bool:
	if effects.size() == 0:
		return false
	for effect in effects:
		if effect:
			effect.use()
	return true
