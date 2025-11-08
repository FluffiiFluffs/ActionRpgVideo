##GLOBAL CLASS PlayerHUD

extends CanvasLayer

@onready var gem_box = %GemBox
@onready var grid_container : GridContainer= %GridContainer
@onready var gem_amount = %GemAmount
var hearts : Array [HeartGUI] = []
var gems:int=0
var actual_gems:int=0
signal gems_changed

func _process(_delta)->void:
	if gems < actual_gems:
		gems += clampi(1, 0, 9999)
		_set_gems_ui()
	elif gems > actual_gems:
		gems -= clampi(1, 0, 9999)
		_set_gems_ui()
		

func _ready():
	for child in grid_container.get_children():
		if child is HeartGUI:
			hearts.append(child)
			child.visible = false

#func update_hp( _hp : int, _max_hp : int ) -> void:
	#update_max_hp(_max_hp)
	#for i in _max_hp:
		#update_heart(i,_hp)
#
#func update_heart( _index : int, _hp: int ) -> void:
	#var _value : int = clampi(_hp - _index * 2, 0, 2)
	#hearts[_index].value = _value
	
func update_hp(_hp: int, _max_hp: int) -> void:
	update_max_hp(_max_hp)
	var hearts_needed := ceili(_max_hp / 2.0)
	var limit = min(hearts_needed, hearts.size())
	for i in range(limit):
		update_heart(i, _hp)

func update_heart(_index: int, _hp: int) -> void:
	var _value: int = clampi(_hp - _index * 2, 0, 2)
	hearts[_index].value = _value





func _set_gems_ui()->void:
	gem_amount.text = str(gems)
	gems_changed.emit()

func _set_gems_ui_quiet()->void:
	gem_amount.text = str(actual_gems)

func update_max_hp( _max_hp : int ) -> void: 
	var _heart_count : int = roundi( _max_hp * 0.5 )
	for i in hearts.size():
		if i < _heart_count:
			hearts[i].visible = true
		else:
			hearts[i].visible = false
			
func give_gems(_value:int)->void:
	actual_gems = clampi(actual_gems + _value, 0, 9999)
	
func take_gems(_value:int)->void:
	actual_gems = clampi(actual_gems - _value, 0, 9999)
	
#for testing
func _unhandled_input(_event):
	if Input.is_action_just_pressed("test3"):
		#take_gems(100)
		return
	if Input.is_action_just_pressed("test4"):
		#give_gems(100)
		return
