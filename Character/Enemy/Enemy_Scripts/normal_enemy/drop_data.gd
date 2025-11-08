##Script to control what an entity drops.[br]
##Resource is used in enemy_state_destroy.drops (array) to define what items an enemy drops
class_name DropData
extends Resource

##What item is dropped.[br]
##Must be Resource type ItemData
@export var item: ItemData
##Controls probability of item dropping.
@export_range(0, 100, 1, "suffix:%") var probability : float = 100
#region
##Minimum amount of items to drop.
@export_range(1,10,1, "suffix:items") var min_amount : int = 1 
##Maximum amount of items to drop.
@export_range(1,10,1, "suffix:items") var max_amount : int = 1 
#endregion


##Returns quantity to drop based off min_amount and max_amount[br]
##Rolls random number. [br]
##If the random number is HIGHER than the probability value, the item will NOT drop.[br]
##if random number was lower, then function returns a number between min_amount and max_amount
func get_drop_count() -> int:
	if randf_range(0,100) >= probability:
		return 0
	return randi_range(min_amount, max_amount)
