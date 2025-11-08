extends CanvasLayer

@onready var positioner = %MenuPositioner
@onready var exit_button = %ExitButton
@onready var shop_name_label = %ShopNameLabel
@onready var gem_amount_label = %GemAmountLabel
@onready var shop_item_container = %ShopItemContainer
@onready var animation_player = %AnimationPlayer
@onready var selected_item = %SelectedItem
@onready var shop_portrait = %ShopkeeperPortrait
@onready var d_item_name = %DItemName
@onready var qdh_separator_2 = %QDHSeparator2
@onready var d_item_desc = %DItemDesc
@onready var price_amount = %PriceAmount
@onready var buy_button = %BuyButton
@onready var audio_stream_player = %AudioStreamPlayer
@onready var item_use_audio_player = %ItemUseAudioPlayer

const HEART = preload("uid://c64lljryccy1y")
const BELL = preload("uid://divifny32focf")
const COIN = preload("uid://bqfg6k38nim57")
const CROW = preload("uid://bfklnqyow6d2l")
const ERROR = preload("uid://cg48ss4s86bvq")
const SELECT = preload("uid://cp6n4c7a7tjl7")

const ITEM_BUTTON = preload("uid://dtnrq00xnuqoo")

var shop_portrait_normal:Texture=null
var shop_portrait_talk:Texture=null
var shop_portrait_special:Texture=null
var shop_open:bool=false
var shop_gems:int=0
var current_selected_item:ItemData=null
var last_item_index:int=0
##Global Script ShopMenu
@export var shop_data:ShopData

func _process(_delta)->void:
	if shop_open==true:
		if shop_gems < PlayerHUD.actual_gems:
			shop_gems += clampi(1, 0, 9999)
			set_shop_gem_ui()
		elif shop_gems > PlayerHUD.actual_gems:
			shop_gems -= clampi(1, 0, 9999)
			set_shop_gem_ui()
	pass

func _ready()->void:
	animation_player.play("closed")
	exit_button.pressed.connect(hide_menu)
	exit_button.focus_entered.connect(exit_entered)
	buy_button.pressed.connect(buy_item)
	#buy_button.focus_entered.connect(setup_buy_neighbors)
	clear_items()
	clear_description()

func setup_shop()->void:
	clear_items()
	#clears textures
	shop_portrait.texture = null
	selected_item.texture = null
	
	#assigns portait textures if available
	if shop_data.shopkeeper.portrait != null:
		shop_portrait_normal = shop_data.shopkeeper.portrait
	else:
		shop_portrait_normal = null
	if shop_data.shopkeeper.portrait_talk != null:
		shop_portrait_talk = shop_data.shopkeeper.portrait_talk
	else:
		shop_portrait_talk = null
	if shop_data.shopkeeper.portrait_special != null:
		shop_portrait_special = shop_data.shopkeeper.portrait_special
	else:
		shop_portrait_special = null
	shop_portrait.texture = shop_portrait_normal
	#Sets the name of the shop
	shop_name_label.text = shop_data.shopname
	make_item_buttons()
	initial_buy_neighbors()
	buy_button.disabled = true

##Makes sure the exit button can be navigated away from
func setup_exit_neighbors()->void:
	var itemchildren = shop_item_container.get_children()
	if itemchildren.size() != 0:
		exit_button.focus_neighbor_bottom = itemchildren[0].get_path()
	exit_button.focus_neighbor_right = itemchildren[0].get_path()
	exit_button.focus_neighbor_top = exit_button.get_path()
	exit_button.focus_neighbor_right = buy_button.get_path()
	
func exit_entered()->void:
	clear_description()
	if shop_open == true:
		play_focused()

func buy_item()->void:
	if current_selected_item == null:
		return
	if current_selected_item.shop_price > PlayerHUD.actual_gems:
		#play deny sound
		play_deny()
		return
	elif current_selected_item.shop_price <= PlayerHUD.actual_gems:
		#Play confirm sound
		play_buy()
		update_buttons_buying()
		PlayerHUD.actual_gems -= current_selected_item.shop_price
		#add item to inventory
		if current_selected_item.use_on_pickup == false:
			GlobalPlayerManager.INVENTORY_DATA.add_item(current_selected_item)
			play_buy()
			update_buttons_buying()
		else:
			if current_selected_item.name == "Heart":
				if GlobalPlayerManager.player.hp == GlobalPlayerManager.player.max_hp:
					#play deny sound
					play_deny()
					return
				else:
					current_selected_item.use()
					play_use_item(HEART)
					play_buy()
					update_buttons_buying()
			else:
				current_selected_item.use()
				play_buy()
				update_buttons_buying()

func play_deny()->void:
	play_sound(ERROR)
func play_confirm()->void:
	play_sound(BELL)
func play_buy()->void:
	play_sound(COIN)
func play_focused()->void:
	play_sound(SELECT)
	
func play_sound(_sound:AudioStream):
	audio_stream_player.stream = _sound
	audio_stream_player.play()

func play_use_item(_sound:AudioStream):
	item_use_audio_player.stream = _sound
	item_use_audio_player.play()


func hide_menu()->void:
	if !animation_player.is_playing():
		play_sound(CROW)
		PlayerHUD.gem_box.visible = true
		animation_player.play("closing")
		await animation_player.animation_finished
		animation_player.play("closed")
		shop_open=false
		get_tree().paused = false
		clear_items()

func show_menu()->void:
	if shop_data == null:
		hide_menu()
		return
	if !animation_player.is_playing():
		await get_tree().process_frame
		get_tree().paused = true
		setup_shop()
		PlayerHUD.gem_box.visible = false
		shop_gems = PlayerHUD.actual_gems
		set_shop_gem_ui()
		animation_player.play("opening")
		await animation_player.animation_finished
		animation_player.play("open")
		setup_exit_neighbors()
		update_buttons_buying()
		exit_button.grab_focus()
		shop_open=true
	
func clear_items()->void:
	for child in shop_item_container.get_children():
		child.queue_free()

func clear_description()->void:
	d_item_name.text = ""
	d_item_desc.text = ""
	qdh_separator_2.visible = false
	selected_item.texture = null
	price_amount.text = ""

#func test_item()->void:
	#var list:= shop_data.shop_item_list
	#for i in list.size():
		#var item:ItemData = list[i]
		#print(item.name)
		#print(item.shop_price)

func make_item_buttons()->void:
	var list:= shop_data.shop_item_list
	for i in list.size():
		var item:ItemData = list[i]
		if item != null:
			last_item_index = i
			var new_shop_button = ITEM_BUTTON.instantiate()
			shop_item_container.add_child(new_shop_button)
			new_shop_button.item_label.text = item.name
			#new_shop_button.price.text = str(item.shop_price)
			new_shop_button.item_texture.texture = item.texture
			new_shop_button.int_price = item.shop_price
			new_shop_button.focus_entered.connect(update_item_description.bind(item, new_shop_button))
			new_shop_button.pressed.connect(focus_buy_button)
	update_buttons_buying()


func focus_buy_button()->void:
	if current_selected_item.shop_price > PlayerHUD.actual_gems:
		buy_button.disabled = true
		play_deny()
		return
	buy_button.disabled = false
	buy_button.grab_focus()
	play_focused()


func update_item_description(_item:ItemData, _button:Button):
	#clear item description
	clear_description()
	update_buttons_buying()
	buy_button_enabler(_item)
	qdh_separator_2.visible = true
	d_item_name.text = _item.name
	d_item_desc.text = _item.shop_description
	price_amount.text = str(_item.shop_price)
	selected_item.texture = _item.texture
	current_selected_item = _item
	play_focused()
	#sets the last item focused to be what the focus goes to when pressing left from buy
	var itemchildren = shop_item_container.get_children()
	if itemchildren.size() != 0:
		buy_button.focus_neighbor_left = _button.get_path()
	buy_button.focus_neighbor_bottom = buy_button.get_path()
	buy_button.focus_neighbor_top = buy_button.get_path()
	buy_button.focus_neighbor_right = buy_button.get_path()	
	

	pass

func buy_button_enabler(_item:ItemData)->void:
	if _item.shop_price > PlayerHUD.actual_gems:
		buy_button.disabled = true
	else:
		buy_button.disabled = false

func update_buttons_buying()->void:
	var button_list = shop_item_container.get_children()
	for child in button_list:
		if child.int_price > PlayerHUD.actual_gems:
			child.disabled = true
		else:
			child.disabled = false

func initial_buy_neighbors()->void:
	var itemchildren = shop_item_container.get_children()
	if itemchildren.size() != 0:
		buy_button.focus_neighbor_left = itemchildren[0].get_path()
	buy_button.focus_neighbor_bottom = buy_button.get_path()
	buy_button.focus_neighbor_top = buy_button.get_path()
	buy_button.focus_neighbor_right = buy_button.get_path()
	play_focused()

func set_shop_gem_ui()->void:
	gem_amount_label.text = str(shop_gems)
	
func _input(_event):
	#if Input.is_action_just_pressed("test1"):
		#if !shop_open:
			#show_menu()
	#if Input.is_action_just_pressed("test2"):
		#if shop_open:
			#hide_menu()
	if shop_open==true:
		if Input.is_action_just_pressed("cancel_input"):
			hide_menu()
		
