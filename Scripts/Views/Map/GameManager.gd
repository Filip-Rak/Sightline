extends Node

class_name Game_Manager

# Attributes
# --------------------

# Exported settings
@export var map_root : Node3D

# Other scripts
var turn_manager : Turn_Manager
var highlight_manager : Highlight_Manager
var game_ui : Game_UI

# Map variables
var tile_matrix = []
const tile_group_name : String = "tiles"
var positional_offset_x : int
var positional_offset_z : int
var x_size : int
var z_size : int

# Units
const unit_group_name : String = "units"

# Selections
var mouse_selection
var selected_action
var targets_and_costs : Dictionary

# Pathfinding
var reachable_tiles_and_costs : Dictionary

# Player
@onready var camera = $PlayerCamera
var player_turn : bool = false

# Game Settings
var const_income = 5

# Ready Functions
# --------------------

func _ready():
	# This is the begining of the scene
	print ("Waiting for players")
	
	# Create other scripts
	turn_manager = Turn_Manager.new()
	add_child(turn_manager)
	
	# Set up signals
	Network.connect("synchronization_complete", on_all_players_loaded)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	turn_manager.connect("new_game_turn", _on_new_game_turn)
	
	# Set up the mouse mode manager
	MouseModeManager.set_game_manager(self)
	MouseModeManager.set_camera(camera)
	MouseModeManager.set_mouse_mode(MouseModeManager.MOUSE_MODE.INSPECTION)
	
	# Set up highligt manager
	highlight_manager = Highlight_Manager.new(self)
	add_child(highlight_manager)
	
	# Load the map and get its properties
	# In the future this is where procedural generation would be added
	var map_loader = Map_Loader.new()
	map_loader.load_map(map_root, tile_group_name)
	
	tile_matrix = map_loader.get_tile_matrix()
	x_size = map_loader.get_x_size()
	z_size = map_loader.get_z_size()
	positional_offset_x = map_loader.get_pos_offset_x()
	positional_offset_z = map_loader.get_pos_offset_z()
	
	# Spawn all the action instances
	# This is required to perform PRCs on them
	for action in Unit_Properties.get_all_actions():
		if !action.is_inside_tree():
			action.set_game_manager(self)
			add_child(action)
			
	# Tell players how many points they start with
	# For now just assign everyone a constant value
	for player_id in PlayerManager.players.keys():
		PlayerManager.set_deployment_points(player_id, 10)

# Process Functions
# --------------------
func _process(_delta : float):
	pass

# External Interaction Functions
# --------------------

# Function for receiving game settings
func set_up(_parameters):
	# Settings for turn manager
	turn_manager.set_up(self)
	
	# Modify the matrix based on the settings
	
	# Set up teams
	# Done by teh host
	if multiplayer.get_unique_id() == 1:
		TeamManager.set_up_teams(tile_matrix)
	
	# Acknowledge completion of finishing the setup proccess
	# Host call the function manually
	if multiplayer.get_unique_id() == 1:
		Network.send_ack(1)
	else:
		Network.rpc_id(1, "send_ack", multiplayer.get_unique_id())

func select_action(action_arg : Action):
	# Execute only if player unit is selected
	# This is a temporary measure because rn the UI is pernament
	# This should be deleted with introduction of dynamic UI
	# Since this fucntion would never be triggered without said UI element being available
	# And such a button would only be available in a situation when the unit is indeed selected
	if !(mouse_selection is Unit || mouse_selection is Unit_Properties.unit_type): return
	
	MouseModeManager.set_mouse_mode(MouseModeManager.MOUSE_MODE.ACTION)
	
	# Discard all the previous highlits
	# Order here is very important!
	highlight_manager.clear_mouse_over_highlight() 
	highlight_manager.clear_mass_highlight()
	
	# Save selected action for on click events
	selected_action = action_arg
	
	# Save targets
	targets_and_costs = action_arg.get_available_targets()
	
	# Highlighting and UI changes are handled by Action superclass
	# Through subclasses in order to make them more customizable
	
func execute_action(target):
	# Only execute if turn belongs to the player
	if !player_turn: return
	
	# Make sure an action is selected
	if selected_action == null: return
	
	# Make sure mouse selection isnt null and selected target is among available ones
	if mouse_selection == null: return
	if targets_and_costs == null: return
	if !targets_and_costs.has("tiles"): return
	if targets_and_costs["tiles"].find(target) == -1: return
	
	# Call execution on the action
	selected_action.perform_action(target)

func disable_turn():
	# Disable certain actions
	player_turn = false
	
	# Reset action points for visualization of next turn
	reset_action_points()
	
	if MouseModeManager.current_mouse_mode == MouseModeManager.MOUSE_MODE.ACTION:
		select_action(selected_action)
	
	# Recalculate highlighting on the screen for the next turn
	highlight_manager.redo_highlighting(false)
	
func enable_turn():
	# Enable certain actions
	player_turn = true
	
	if MouseModeManager.current_mouse_mode == MouseModeManager.MOUSE_MODE.ACTION:
		select_action(selected_action)
	
	# Recalculate highlighting on the screen for the next turn
	highlight_manager.redo_highlighting(player_turn)
	
	# Update player's deployment points
	if turn_manager.get_turn_num() > 1:
		PlayerManager.offset_deployment_points(multiplayer.get_unique_id(), const_income)

func reset_action_points():
	var units = PlayerManager.get_units(multiplayer.get_unique_id())
	for unit in units:
		unit.reset_action_points()

# Link Functions
# --------------------
func on_all_players_loaded():
	print ("All players loaded")
	
	# Start the first turn
	turn_manager.begin_game()

func peer_disconnected(id : int):
	# If host diconnects the game is over
	if id == 1: return
	
	# If host remains connected, they will reasing units of the disconnected players to their teammates
	if multiplayer.get_unique_id() != 1: return
	
	# If the player has teammates distribute their units among them
	var dsc_units = PlayerManager.get_units(id)
	var dsc_teammates = PlayerManager.get_teammates_ids(id)
	
	# Number of teammates
	var num_teammates  = dsc_teammates.size()
	
	# Check if there are any teammates to distribute the units to
	if num_teammates == 0: return 
	
	# Distribute units among teammates evenly
	for i in range(dsc_units.size()):
		# Assign each unit to a teammate in a round-robin fashion
		var teammate_index = i % num_teammates
		var teammate_id = dsc_teammates[teammate_index]
		
		# The index of a unit will always remain 0 because we are actively reasigning them
		PlayerManager.rpc("reassign_unit", dsc_units[0].get_path(), id, teammate_id)
	
	print ("---HOST : UNIT MIGRATION RESULTS---")
	for player in PlayerManager.get_players():
		print("Owner: %s" % [player])
		print("Units %s" % [PlayerManager.get_units(player)])

func _on_new_game_turn():
	if turn_manager.get_turn_num() > 1:
		TeamManager.update_score(get_tile_matrix())

# Setters
# --------------------
func set_mouse_selection(selection):
	# Reassign the global var
	mouse_selection = selection

func set_game_ui(reference : Game_UI):
	game_ui = reference

# Getters
# --------------------
func get_tile_group_name() -> String:
	return tile_group_name

func get_unit_group_name() -> String:
	return unit_group_name
	
func get_tile_matrix() -> Array:
	return tile_matrix

func get_mouse_selection():
	return mouse_selection
