extends CanvasLayer

# Attributes
# --------------------

# Nodes
@export var game_manager : Game_Manager
@export var player_turn_label : Label
@export var player_name_label : Label
@export var time_left_label : Label
@export var buy_menu : PanelContainer

var game_in_progress = false

# Ready Functions
# --------------------
func _ready():
	set_externals()
	set_UI()
	
func set_externals():
	if game_manager:
		game_manager.set_game_ui(self)

func set_UI():
	populate_buy_menu()
	player_name_label.text = "Player: " + PlayerManager.get_player_name(multiplayer.get_unique_id()) + " " + str(multiplayer.get_unique_id())

func populate_buy_menu():
	var hbox
	for child in buy_menu.get_children():
		if child is HBoxContainer:
			hbox = child
			break

	for unit_id in PlayerUnit.get_spawnable_types():
		var button = Button.new()
		button.text = PlayerUnit.get_display_name(unit_id)
		button.connect("button_down", Callable(self, "_on_unit_buy_button_pressed").bind(unit_id))
		hbox.add_child(button)

# Proccess
# --------------------
func _process(_delta : float):
	handle_timer()

func handle_timer():
	if game_in_progress:
		var time_spent = game_manager.turn_manager.time_spent_in_turn
		var time_max = game_manager.turn_manager.time_limit
		
		if game_manager.turn_manager.set_timer_type == game_manager.turn_manager.TIMER_TYPE.DISABLED:
			time_left_label.text = "Time passed: " + str(floor(time_spent))
		else:
			time_left_label.text = "Time left: " + str(floor(time_max - time_spent))
		 
		
# External Control Functions
# --------------------
func update_turn_ui(player_id : int, _given_time : float):
	player_turn_label.text = PlayerManager.get_player_name(player_id)
	game_in_progress = true

# Links
# --------------------
func select_unit_for_spawn(type : PlayerUnit.unit_type):

	var action_arg = PlayerUnit.get_actions(type)[0]
	if action_arg:
			game_manager.set_mouse_selection(type)
			game_manager.select_action(action_arg)
			
	else:
		print("Unit not spawnable")

func _on_end_turn_button_down():
	if game_manager:
		game_manager.turn_manager.try_skip_turn()

func _on_move_button_button_down():
	game_manager.select_action(PlayerUnit.type_properties[PlayerUnit.unit_type.IFV]["actions"][1])

func _on_deploy_button_down():
	if !buy_menu: return
	
	# Toggle visibility of the buy menu
	buy_menu.visible = !buy_menu.visible

func _on_unit_buy_button_pressed(unit_id : int):
	var spawn_action = PlayerUnit.get_action(unit_id, Action_Spawn.get_internal_name())
	if spawn_action:
			game_manager.set_mouse_selection(unit_id)
			game_manager.select_action(spawn_action)		
	else:
		print("Unit not spawnable")
