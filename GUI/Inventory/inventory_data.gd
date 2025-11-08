##This script is used to setup the player_inventory.tres
class_name InventoryData
extends Resource

## Array of [code]SlotData[/code] resources representing the player's inventory.[br][br]
## [b]Steps[/b]
## [codeblock]
## @export var slots : Array[SlotData]
## [/codeblock]
## [b]Details[/b][br]
## Exported so it can be set and reordered in the Inspector.[br]
## Each element is a [code]SlotData[/code] resource that describes one inventory slot.[br]
## Used throughout the script to iterate, connect signals, and persist inventory state.[br]
## [b]Returns[/b][br]
## No return value.
@export var slots : Array[SlotData]

func _init() -> void:
	connect_slots()
	
## Determines whether an item can be added to the inventory and returns a boolean.[br][br]
## [b]Steps[/b]
## [codeblock]
## # only checks if the item already exists in the inventory
## for slot in slots:
##     if slot:
##         if slot.item_data == item:
##             slot.quantity += count
##             return true
##
## for i in slots.size():
##     if slots[i] == null: # checks for empty slot
##         var new_slot_data = SlotData.new()
##         new_slot_data.item_data = item
##         new_slot_data.quantity = count
##         slots[i] = new_slot_data
##         new_slot_data.changed.connect(slot_changed)
##         return true
##
## print("Inventory FULL")
## return false
## [/codeblock]
## [b]Details[/b][br]
## Checks for an existing stack of the same [code]item[/code]. If found, increases [code]quantity[/code] by [code]count[/code] and succeeds.[br]
## If no stack exists, looks for the first empty entry in [code]slots[/code] and creates a new [code]SlotData[/code] with [code]item_data[/code] and [code]quantity[/code] set.[br]
## Connects the new slot's [code]changed[/code] signal to [code]slot_changed[/code] so inventory updates propagate.[br]
## If every slot is occupied, logs [code]"Inventory FULL"[/code] and fails.[br]
## Side effects: may mutate an existing slot's [code]quantity[/code] or insert a new [code]SlotData[/code] into [code]slots[/code].[br]
## Parameters: [code]item: ItemData[/code] to add, [code]count: int[/code] amount to add (default 1).[br]
## [b]Returns[/b][br]
## [code]true[/code] if the item was stacked or placed into an empty slot, otherwise [code]false[/code].
func add_item(item:ItemData, count:int=1 ) -> bool:
	#only checks if the item already exists in the inventory
	for slot in slots:
		if slot:
			if slot.item_data == item:
				slot.quantity += count
				return true
	for i in slots.size():
		if slots[i] == null: #checks for empty slot
			var new_slot_data = SlotData.new()
			new_slot_data.item_data = item
			new_slot_data.quantity = count
			slots[i] = new_slot_data
			new_slot_data.changed.connect(slot_changed)
			return true
	print("Inventory FULL")
	return false

## Loops over inventory slots and, when a slot exists, connects its [code]changed[/code] signal to [code]slot_changed[/code].[br][br]
## [b]Steps[/b]
## [codeblock]
## for slot in slots:
##     if slot:
##         slot.changed.connect(slot_changed)
## [/codeblock]
## [b]Details[/b][br]
## Iterates all entries in [code]slots[/code].[br]
## For each non-null slot, connects its [code]changed[/code] signal so downstream logic (e.g., calling [code]emit_changed()[/code]) can react via [code]slot_changed[/code].[br]
## [b]Returns[/b][br]
## No return value.
func connect_slots() -> void:
	for slot in slots:
		if slot:
			slot.changed.connect(slot_changed)

				
## Removes slots whose quantity has reached zero and notifies listeners.[br][br]
## [b]Steps[/b]
## [codeblock]
## for s in slots:
##     if s and s.quantity < 1:
##         s.changed.disconnect(slot_changed)
##         var index = slots.find(s)
##         slots[index] = null
##         emit_changed()
## [/codeblock]
## [b]Details[/b][br]
## Triggered from the [code]emit_changed[/code] path in [code]slot_data.gd[/code].[br]
## Only runs its removal logic when a slot's [code]quantity[/code] is less than 1.[br]
## Disconnects the slot's [code]changed[/code] signal from [code]slot_changed[/code] before clearing the slot entry.[br]
## Replaces the empty slot with [code]null[/code] and calls [code]emit_changed()[/code] to propagate the update.[br]
## [b]Returns[/b][br]
## No return value.
func slot_changed() -> void:
	for s in slots:
		if s:
			if s.quantity < 1:
				s.changed.disconnect(slot_changed)
				var index = slots.find(s)
				slots[index] = null
				emit_changed()

				
				
## Saves the player's inventory slots into a new Array for persistence.[br][br]
## [b]Steps[/b]
## [codeblock]
## var item_save: Array = []
## for i in slots.size():
##     item_save.append(item_to_save(slots[i]))
## return item_save
## [/codeblock]
## [b]Details[/b][br]
## Creates an empty Array to collect per-slot data.[br]
## Iterates through the player's inventory ([code]slots[/code]).[br]
## Calls [code]item_to_save()[/code] for each slot; the returned Dictionary is appended.[br]
## [b]Returns[/b][br]
## Array of Dictionaries, one per slot.
func get_save_data() -> Array:
	var item_save : Array = []
	for i in slots.size():
		item_save.append(item_to_save(slots[i]))
	return item_save
	
	
## Stores quantity and item resource UID into a Dictionary.[br][br]
## [b]Steps[/b]
## [codeblock]
## var result := { item = "", quantity = 0 }
## if slot != null:
##     result.quantity = slot.quantity
## if slot and slot.item_data != null:
##     result.item = slot.item_data.resource_path
## return result
## [/codeblock]
## [b]Details[/b][br]
## Creates a result Dictionary with [code]item[/code] and [code]quantity[/code] defaulted to safe values.[br]
## Copies [code]slot.quantity[/code] when a valid [code]slot[/code] is provided.[br]
## When [code]slot.item_data[/code] exists, stores its resource UID from [code]resource_path[/code] into [code]item[/code].[br]
## [b]Returns[/b][br]
## Dictionary with [code]item[/code] as UID String and [code]quantity[/code] as integer.
func item_to_save(slot: SlotData) -> Dictionary:
	var result = { item = "", quantity = 0 }
	if slot != null:
		# Assigns item's quantity to key "quantity" in dictionary "result"
		result.quantity = slot.quantity
		if slot.item_data != null:
		# Assigns item resource path UID to "item" key in dictionary "result"
			result.item = slot.item_data.resource_path
	return result
	
##Used to load the game.[br]
##parse_save_data(current_save.items)
func parse_save_data( save_data : Array ) -> void:
	var array_size = slots.size() #stores array size
	slots.clear() #clears all items in slots array
	slots.resize( array_size ) #sets slots array size (fills with null values)
	for i in save_data.size(): #iterates and assigns new_slot objects to each slot in player inventory
		slots[ i ] = item_from_save( save_data[ i ] )
	connect_slots() #connects new items to inventory


##Takes JSON data from parse_save_data() function. Assigns values to a new object (new_slot).[br]
##Returns the new_slot object to be assigned to player's inventory[br]
##item_from_save(save_data[i]). Used in loop that iterates over slots array in inventory
func item_from_save( save_object : Dictionary ) -> SlotData:
	if save_object.item == "": #checks if save object is empty
		return null #if it's empty, then an empty slot is created
	var new_slot : SlotData = SlotData.new() #creates new SlotData resource, assigned to new_slot
	new_slot.item_data = load( save_object.item ) #loads save_object.item (resource path) into new_slot.item_data
	new_slot.quantity = int( save_object.quantity ) #converts JSON string to int from save_object.quantity. Assigns value to new_slot.quantity
	return new_slot #new_slot (item to be loaded/into player's inventory) returned to be used...
	

func use_item (item :ItemData, count:int=1) -> bool:
	for slot in slots:
		if slot:
			if slot.item_data == item and slot.quantity >= count:
				slot.quantity -= count
				return true
	return false
