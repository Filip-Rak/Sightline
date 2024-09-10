extends CanvasLayer

# Attributes
# --------------------

class_name Game_UI

# Scripts
@export var game_manager : Game_Manager

# Buy menu
@export var _deploy_button : Button
@export var buy_menu : PanelContainer

# Turn panel
@export var player_turn_label : Label
@export var turn_num_label : Label
@export var time_left_label : Label

# Lower Section
@export var lower_section_hbox : HBoxContainer

# Middle panel
@export var inspection_panel_empty : PanelContainer

# Unit selection panel
@export var unit_selection_panel : PanelContainer
@export var unit_selection_name : Label
@export var unit_selection_action : Label
@export var unit_selection_hp : Label
@export var unit_selection_sight : Label
@export var unit_selection_res : Label
@export var unit_selection_owner : Label

# Tile selection panel
@export var tile_selection_panel : PanelContainer
@export var tile_selection_name : Label
@export var tile_selection_defense : Label
@export var tile_selection_movement : Label
@export var tile_selection_spawn : Label
@export var tile_selection_value : Label
@export var tile_selection_owner : Label
@export var unit_grid_container : GridContainer

# Debug
@export var debug_crosshair : Sprite2D
@export var debug_rect : ReferenceRect

# Upper right section
@export var player_name_label : Label
@export var team_name_label : Label
@export var score_vbox: VBoxContainer

# Status
var game_in_progress = false
var _tracked_unit : Unit
var _tracked_tile : Tile

# Tooltip
var _tooltip_timer : SceneTreeTimer = null
@export var _tooltip_show_time_delay : float = 0.5
@export var _tooltip_pos_gap : int = 4	# Hbox.separation has been deleted with 4.2 so it's a constant

# Ready Functions
# --------------------
func _ready():
	set_externals()
	set_UI()
	
func set_externals():
	if game_manager: game_manager.set_game_ui(self)
	MouseModeManager.set_game_ui(self)
	
	# Set signals
	PlayerManager.connect("deployment_points_update", _on_deployment_points_update)
	Network.connect("synchronization_complete", _on_sync_complete)

func set_UI():
	# Buy menu
	populate_buy_menu()
	buy_menu.visible = false
	
	# Player and team names
	# In case of custom names, the line below should be updated with the custom name in _on_sync_complete function
	team_name_label.text = "Team: %s" % PlayerManager.get_team_id(multiplayer.get_unique_id())
	player_name_label.text = PlayerManager.get_player_name(multiplayer.get_unique_id()) + " " + str(multiplayer.get_unique_id())
	
	# Clear the score_vbox from placeholders
	# Filled with data in _on_sync_complete
	for child in score_vbox.get_children():
		child.queue_free()
		
	# Enable only inspection middle panel
	_set_element_activity(unit_selection_panel, false)
	_set_element_activity(tile_selection_panel, false)
	_set_element_activity(inspection_panel_empty, true)

func populate_buy_menu():
	var hbox
	for child in buy_menu.get_children():
		if child is HBoxContainer:
			hbox = child
			break

	for unit_type in Unit_Properties.get_spawnable_types():
		var button = Button.new()
		button.text = _prepare_buy_button_string(unit_type)
		button.set_meta("type", unit_type)
		button.connect("button_down", Callable(self, "_on_unit_buy_button_pressed").bind(unit_type))
		hbox.add_child(button, true)

func _prepare_buy_button_string(type : Unit_Properties.unit_type) -> String:
	var spawn_action : Action_Spawn = Unit_Properties.get_action(type, Action_Spawn.get_internal_name())
	var unit_name : String = Unit_Properties.get_display_name(type)
	var price : int = spawn_action._unit_cost
	var availability : int = spawn_action.get_usage_limit()
	var cooldown_left : int = spawn_action.get_cooldown_left()
	
	var text : String = "%s |%d|%d|%d" %[unit_name, price, availability, cooldown_left]
	
	return text
	
# Proccess
# --------------------
func _process(_delta : float):
	handle_timer()
	handle_UI_mask()

func handle_timer():
	if game_in_progress:
		var time_spent = game_manager.turn_manager.time_spent_in_turn
		var time_max = game_manager.turn_manager.time_limit
		
		if game_manager.turn_manager.set_timer_type == game_manager.turn_manager.TIMER_TYPE.DISABLED:
			time_left_label.text = "Time passed: " + str(floor(time_spent))
		else:
			time_left_label.text = "Time left: " + str(floor(time_max - time_spent))

# Checks if mouse is over UI elements
func handle_UI_mask():
	# Find out if the mouse over UI
	var mouse_in_mask = false
	for ui_element in get_tree().get_nodes_in_group("ui_mask"):
		var mouse_pos = get_viewport().get_mouse_position()
		if ui_element.get_global_rect().has_point(mouse_pos):
			mouse_in_mask = true
	
	# Tell mouse to disable hit detection
	MouseModeManager.set_suppress_raycast(mouse_in_mask)

# External Control Functions
# --------------------
func update_turn_ui(player_id : int, _given_time : float, turn_num : int):
	player_turn_label.text = PlayerManager.get_player_name(player_id)
	game_in_progress = true
	turn_num_label.text = "Turn: %d" % turn_num
	
	update_buy_menu()

func inspect_unit(unit : Unit):
	# Set visibility to panels
	_set_element_activity(unit_selection_panel, true)
	_set_element_activity(tile_selection_panel, false)
	_set_element_activity(inspection_panel_empty, false)
	
	# Update unit label's visual properties
	_track_unit(unit)
	_track_tile(null)
	
	# Set unit details
	_set_up_unit_details(unit)
	
	# Set action buttons
	_set_up_action_buttons(unit)

func inspect_tile(tile : Tile):
	# Set visibility to panels
	_set_element_activity(unit_selection_panel, false)
	_set_element_activity(tile_selection_panel, true)
	_set_element_activity(inspection_panel_empty, false)
	
	# Update trackers
	_track_unit(null)
	_track_tile(tile)
	
	# Update unit grid container
	_set_up_unit_grid_container(tile)
	
	# Update tile details
	_set_up_tile_details(tile)

func deselect_inspection():
	# Set visibility to panels
	_set_element_activity(unit_selection_panel, false)
	_set_element_activity(tile_selection_panel, false)
	_set_element_activity(inspection_panel_empty, true)
	
	# Update unit label's visual properties
	_track_unit(null)
	_track_tile(null)

func select_in_ui(unit : Unit):
	MouseModeManager.handle_inspection(unit)

func update_buy_menu():
	var hbox
	for child in buy_menu.get_children():
		if child is HBoxContainer:
			hbox = child
			break
			
	for child in hbox.get_children():
		if child is Button:
			child.text = _prepare_buy_button_string(child.get_meta("type"))

func update_unit_grid():
	if _tracked_tile:
		_set_up_unit_grid_container(_tracked_tile)

# Private Methods
# --------------------
func _update_score_vbox():
	# Clear the vbox
	for child in score_vbox.get_children():
		child.queue_free()
	
	# Fill the vbox with new content
	var team_ids : Array = TeamManager.get_team_ids()
	for id in team_ids:
		var label = Label.new()
		label.text = "Team %s: %s" % [id, TeamManager.get_team_score(id)]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		score_vbox.add_child(label, true)

func _set_up_unit_details(unit : Unit):
	# Display name
	var unit_name = Unit_Properties.get_display_name(unit.get_type())
	unit_selection_name.text = unit_name
	
	# Action points
	var ac_left = unit.get_action_points_left()
	if PlayerManager.get_team_id(unit.get_player_owner_id()) != PlayerManager.get_my_team_id():
		ac_left = "?"
		
	var ac_max = Unit_Properties.get_action_points_max(unit.get_type())
	unit_selection_action.text = "Action: %s/%s" % [ac_left, ac_max]
	
	# Health points
	var hp_left = ceil(unit.get_hit_points_left())
	var hp_max = Unit_Properties.get_hit_points_max(unit.get_type())
	unit_selection_hp.text = "HP: %s/%s" % [hp_left, hp_max]
	
	# Sight range
	var sight = Unit_Properties.get_action_points_max(unit.get_type())
	unit_selection_sight.text = "Sight: %s" % sight
	
	# Resistances
	var HE_res = Unit_Properties.get_he_resistance(unit.get_type()) 
	var AP_res = Unit_Properties.get_ap_resistance(unit.get_type()) 
	unit_selection_res.text = "RES: %.1f/%.1f" % [AP_res, HE_res]
	
	# Owner
	var player_name = PlayerManager.get_player_name(unit.get_player_owner_id())
	unit_selection_owner.text = "Owner: %s" % player_name

func _set_up_action_buttons(unit : Unit):
	# Set up action buttons
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
			button.disconnect("mouse_entered", _on_action_button_mouse_entered)
			button.disconnect("mouse_exited", _on_action_button_mouse_exited)
		
		# Check if there's an action for this button index
		if i < actions.size():
			var action = actions[i]
			
			# Assign the button's text to the action's display name
			button.text = action.get_display_name()
			
			# Connect the button's "button_down" signal to function, passing the action as an argument
			button.connect("button_down", Callable(self, "_on_action_button_down").bind(action, unit))
			button.connect("mouse_entered", Callable(self, "_on_action_button_mouse_entered").bind(button, action))
			button.connect("mouse_exited", Callable(self, "_on_action_button_mouse_exited").bind(action))
			
			# Enable the button since it has an assigned action
			button.disabled = false
		else:
			# Disable buttons without actions
			button.text = ""
			button.disabled = true
			
	# Handle too many actions scenario
	if actions.size() > action_buttons.size():
		print("inspect_unit() -> Warning: Too many actions, not all actions will be assigned to buttons")

func _set_up_unit_grid_container(tile : Tile):
	# Reset unit grid container
	for child in unit_grid_container.get_children():
		child.queue_free()
	
	# Fill the unit grid container
	var units = tile.get_units_in_tile()
	for unit : Unit in units:
		var unit_button = Button.new()
		unit_button.connect("button_down", Callable(self, "select_in_ui").bind(unit))
		
		# Set the string of a unit button
		var ap_left = unit.get_action_points_left()
		var display_name = Unit_Properties.get_display_name(unit.get_type())
		var hp_left = unit.get_hit_points_left()
		var unit_text = "%d|%s|%d" % [ap_left, display_name, ceil(hp_left)]
		
		# Make a change for different team
		if PlayerManager.get_team_id(unit._player_owner_id) != PlayerManager.get_my_team_id():
			unit_text = "%s|%d" % [display_name, ceil(hp_left)]
		
		unit_button.text = unit_text
		unit_grid_container.add_child(unit_button, true)

func _set_up_tile_details(tile : Tile):
	# Display name
	var tile_name = Tile_Properties.get_display_name(tile.get_type())
	tile_selection_name.text = tile_name
	
	# Defense modifier
	var def = Tile_Properties.get_defense_modifier(tile.get_type())
	tile_selection_defense.text = "Defense: %.1f" % def
	
	# Movement cost
	var movement_cost = Tile_Properties.get_movement_cost(tile.get_type())
	tile_selection_movement.text = "Movement: %.1f" % movement_cost
	
	# Is a spawn
	if tile.get_is_a_spawn():
		tile_selection_spawn.text = "Spawn"
		tile_selection_spawn.visible = true
	else:
		tile_selection_spawn.visible = false
		
	# Point value
	var value = tile.get_point_value()
	if value > 0:
		tile_selection_value.text = "Value: %.1f" % value
		tile_selection_value.visible = true
	else:
		tile_selection_value.visible = false
		
	# Team owner
	var team_owner = tile.get_team_id()
	if team_owner > 0:
		tile_selection_owner.text = "Team owner: %s" % team_owner
		tile_selection_owner.visible = true
	else:
		tile_selection_owner.visible = false
		
# Links
# --------------------
func _on_action_button_down(action : Action, unit : Unit):
	game_manager.mouse_selection = unit
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

func _on_deployment_points_update():
	var new_val : float = PlayerManager.get_deployment_points(multiplayer.get_unique_id())
	_deploy_button.text = "%d" % int(new_val)

func _on_sync_complete():
	# Set signals to additional dependencies
	game_manager.get_turn_manager().connect("new_game_turn", _on_new_game_turn)
	
	# Set and update the score vbox
	# Not most efficient but it will be rewritten anyway
	_update_score_vbox()
		
func _on_new_game_turn():
	# Later add update of turn UI and remove it from turn manager along with self reference 
	_update_score_vbox()

func _on_unit_details_changed():
	_set_up_unit_details(_tracked_unit)

func _on_unit_sel_tile_button():
	if _tracked_unit:
		var pos = _tracked_unit.get_matrix_tile_position()
		var tile : Tile = game_manager.get_tile_matrix()[pos.x][pos.z]
		MouseModeManager.handle_inspection(tile)

func _on_tile_data_changed():
	_set_up_tile_details(_tracked_tile)
	_set_up_unit_grid_container(_tracked_tile)

func _on_action_button_mouse_entered(button : Button, action : Action):
	# Create and start the timer when the mouse enters
	_tooltip_timer = get_tree().create_timer(_tooltip_show_time_delay)  # Delay in seconds
	_tooltip_timer.connect("timeout", Callable(self, "_on_tooltip_timeout").bind(button, action))

func _on_tooltip_timeout(button : Button, action : Action):
	# Get the tooltip
	var tooltip : Action_Tooltip = action.get_tooltip_instance()
	tooltip.position.y = unit_selection_panel.global_position.y - tooltip.size.y - _tooltip_pos_gap
	tooltip.position.x = button.global_position.x
	
	# Add to the tree, making the tooltip visible
	add_child(tooltip)

func _on_action_button_mouse_exited(action : Action):
	# Stop the timer and remove tooltip if it was visible
	if _tooltip_timer && _tooltip_timer.is_connected("timeout",_on_tooltip_timeout):
		_tooltip_timer.disconnect("timeout", _on_tooltip_timeout)
		_tooltip_timer = null
	
	# Get the tooltip
	var tooltip : Action_Tooltip = action.get_tooltip_instance()
	
	# Remove the tooltip from tree, making it invisible
	if tooltip.is_inside_tree():
		remove_child(tooltip)

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

func _track_unit(new_track : Unit):
	# Disable old selection
	if is_instance_valid(_tracked_unit):
		# Label content
		var label_content : Unit_Label_Content = _tracked_unit.get_label_conent()
		if label_content: label_content.set_selection_vis(false)
		
		# Signals
		_tracked_unit.disconnect("unit_details_changed", _on_unit_details_changed)
	
	# Enable new selection
	if is_instance_valid(new_track):
		# Label content
		var label_content : Unit_Label_Content = new_track.get_label_conent()
		if label_content: label_content.set_selection_vis(true)
		
		# Signals
		if !new_track.is_connected("unit_details_changed", _on_unit_details_changed):
			new_track.connect("unit_details_changed", _on_unit_details_changed)
	
	# Save the selection
	_tracked_unit = new_track

func _track_tile(new_track : Tile):
	# Delete old reference
	if is_instance_valid(_tracked_tile):
		# Disconnect the signal
		_tracked_tile.disconnect("tile_data_changed", _on_tile_data_changed)
	
	# Set new reference
	if is_instance_valid(new_track):
		# Connect the signal
		if !new_track.is_connected("tile_data_changed", _on_tile_data_changed):
			new_track.connect("tile_data_changed", _on_tile_data_changed)
	
	_tracked_tile = new_track
