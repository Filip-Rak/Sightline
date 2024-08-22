extends CanvasLayer

# Attributes
# --------------------

class_name Game_UI

# Nodes
@export var game_manager : Game_Manager
@export var player_turn_label : Label
@export var player_name_label : Label
@export var time_left_label : Label
@export var buy_menu : PanelContainer
@export var inspection_panel_empty : PanelContainer
@export var unit_selection_panel : PanelContainer
@export var tile_selection_panel : PanelContainer

var game_in_progress = false

# Ready Functions
# --------------------
func _ready():
	set_externals()
	set_UI()
	
func set_externals():
	if game_manager: game_manager.set_game_ui(self)
	MouseModeManager.set_game_ui(self)

func set_UI():
	populate_buy_menu()
	player_name_label.text = "Player: " + PlayerManager.get_player_name(multiplayer.get_unique_id()) + " " + str(multiplayer.get_unique_id())

func populate_buy_menu():
	var hbox
	for child in buy_menu.get_children():
		if child is HBoxContainer:
			hbox = child
			break

	for unit_type in Unit_Properties.get_spawnable_types():
		var button = Button.new()
		button.text = Unit_Properties.get_display_name(unit_type)
		button.connect("button_down", Callable(self, "_on_unit_buy_button_pressed").bind(unit_type))
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

func inspect_unit(unit : Unit):
	# Set visibility to panels
	_set_element_activity(unit_selection_panel, true)
	_set_element_activity(tile_selection_panel, false)
	_set_element_activity(inspection_panel_empty, false)
	
	var action_buttons: Array = get_tree().get_nodes_in_group("action_buttons")
	var actions: Array = Unit_Properties.get_actions(unit.get_type())
	
	# Ignore certain actions in setting up buttons
	actions = _action_buttons_filter(actions)
	
	# Iterate over all action buttons
	for i in range(action_buttons.size()):
		var button : Button = action_buttons[i] 
		
		# Disconnect any existing connections to avoid duplicates
		if button.is_connected("button_down", _on_action_button_down):
			button.disconnect("button_down", _on_action_button_down)
		
		# Check if there's an action for this button index
		if i < actions.size():
			var action = actions[i]
			
			# Assign the button's text to the action's display name
			button.text = action.get_display_name()
			
			# Connect the button's "button_down" signal to function, passing the action as an argument
			button.connect("button_down", Callable(self, "_on_action_button_down").bind(action))
			
			# Enable the button since it has an assigned action
			button.disabled = false
		else:
			# Disable buttons without actions
			button.text = ""
			button.disabled = true
			
	# Handle too many actions scenario
	if actions.size() > action_buttons.size():
		print("inspect_unit() -> Warning: Too many actions, not all actions will be assigned to buttons")

func inspect_tile(_tile : Tile):
	_set_element_activity(unit_selection_panel, false)
	_set_element_activity(tile_selection_panel, true)
	_set_element_activity(inspection_panel_empty, false)
	
# Links
# --------------------
func _on_action_button_down(action : Action):
	game_manager.select_action(action)

func _on_end_turn_button_down():
	if game_manager:
		game_manager.turn_manager.try_skip_turn()

func _on_deploy_button_down():
	if !buy_menu: return
	
	# Toggle visibility of the buy menu
	buy_menu.visible = !buy_menu.visible

func _on_unit_buy_button_pressed(unit_type : int):
	var spawn_action = Unit_Properties.get_action(unit_type, Action_Spawn.get_internal_name())
	if spawn_action:
			game_manager.set_mouse_selection(unit_type)
			game_manager.select_action(spawn_action)
	else:
		print("_on_unit_buy_button_pressed() -> Unit not spawnable")

# Utility
# --------------------
func _action_buttons_filter(arr : Array) -> Array:
	# List of actions to avoid
	var filter_out : Array = [Action_Spawn.get_internal_name()]
	
	# List of valid actions
	var reference : Array = []
	
	var valid : bool = true
	# Check every action given
	for action in arr:
		# Compare internal names to all the internal names
		for banned_entry in filter_out:
			# If name is the same, mark it as invalid an break
			if banned_entry == action.get_internal_name():
				valid = false
				break
		# add the action if valid
		if valid:
			reference.append(action)
			
		# Reset the flag
		valid = true
			
	return reference

func _set_element_activity(element, value : bool):
	# element.disable = value
	element.visible = value
