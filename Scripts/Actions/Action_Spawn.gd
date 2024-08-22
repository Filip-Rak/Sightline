extends Action

class_name Action_Spawn

# Attributes
# --------------------

# Spawning properties
var _unit_cost : int 
var _spawns_with_action_points : bool

# Constructor
# --------------------
func _init(cost : int, availability : int, spawn_cooldown : int = 0, spawns_with_action_points : bool = true):
	# Subclass variables
	_unit_cost = cost
	_spawns_with_action_points = spawns_with_action_points
		
	# Initiliaze parent's constructor
	var ap_cost = 0
	var usage_limit = availability
	var cooldown = spawn_cooldown
	super._init("", "", ap_cost, usage_limit, cooldown)

# Public Methods
# --------------------
func get_available_targets() -> Dictionary:
	
	# Get tile_matrix
	var tile_matrix = _game_manager.get_tile_matrix()
	
	# Save mouse_selection as unit
	var unit : Unit_Properties.unit_type = _game_manager.mouse_selection
	
	# Find all the tiles suitable for spawning
	var good_tiles = []
	for i in _game_manager.x_size:
		for j in _game_manager.z_size:
				if tile_matrix[i][j].get_is_a_spawn():
					if tile_matrix[i][j].get_team_id() == PlayerManager.get_my_team_id():
						if Tile_Properties.get_accesible_to(tile_matrix[i][j].get_type()).find(unit) != -1:
							good_tiles.append(tile_matrix[i][j])
	
	# Highlight these tiles
	_game_manager.highlight_manager.mass_highlight_tiles(good_tiles)
	
	# Return tiles and values
	var costs : Array = []
	for tile in good_tiles:
		costs.append(_unit_cost)

	return {"tiles": good_tiles, "costs": costs}

func perform_action(_target : Tile):
	# Get path for RPC call
	var spawn_path : NodePath = _target.get_path()
	var tree : NodePath = self.get_path()
	var player_id : int = multiplayer.get_unique_id()
	
	rpc("spawn_unit", spawn_path, _game_manager.mouse_selection, player_id, tree) 
	
	# Clear all selections after spawning - consider not doing so for 'shift' effect
	_game_manager.highlight_manager.clear_mouse_over_highlight()
	_game_manager.highlight_manager.clear_mass_highlight()	
	_game_manager.mouse_selection = null

	# Change mouse mode to inspect
	MouseModeManager.set_mouse_mode(MouseModeManager.MOUSE_MODE.INSPECTION)

# Remote Procedure Calls
# --------------------
@rpc("any_peer", "call_local")
func spawn_unit(target_tile_path : NodePath, unit_to_spawn : Unit_Properties.unit_type, spawning_player: int, parent_node_path : NodePath):
	# Get the tile to spawn in
	var target_tile = get_node(target_tile_path)
	
	# Instantiate the unit and set it's properties
	var spawned_unit = Unit_Properties.get_scene_of_type(unit_to_spawn).instantiate()
	spawned_unit.position = target_tile.position
	spawned_unit.set_player_owner(spawning_player)
	spawned_unit.set_matrix_tile_position(target_tile.get_matrix_position())
	spawned_unit.add_to_group(_game_manager.unit_group_name)
	
	# Update the tile properties
	target_tile.add_unit_to_tile(spawned_unit)
	
	# Add the unit to the tree
	var tree = get_node(parent_node_path)
	tree.add_child(spawned_unit)
	
	# Add the unit to list of units of a player
	PlayerManager.add_unit(spawning_player, spawned_unit)
	
	# Recalculate the highlighting for other players
	if !_game_manager.player_turn: _game_manager.highlight_manager.redo_highlighting(_game_manager.player_turn)

# Getters
# --------------------
static func get_internal_name() -> String:
	return "Action_Spawn"
