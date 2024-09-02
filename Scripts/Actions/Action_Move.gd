extends Action

class_name Action_Move

# Attributes
# --------------------

# Default constants
const _DISPLAY_NAME : String = "action_move_default_display_name"
const _DESCRIPTION : String = "action_move_default_description"

# Pathfinding
var available_tiles : Array

# Constructor
# --------------------

func _init(display_name : String = "", description : String = ""):
	
	# Check if a custom name and description are not given
	if display_name == "": display_name = _DISPLAY_NAME
	if description == "": description = _DESCRIPTION
	
	# Initiliaze parent's constructor
	var ap_cost = 0
	var usage_limit = 0
	var cooldown = 0
	super._init(display_name, description, ap_cost, usage_limit, cooldown)

# Public Methods
# --------------------

# Returns tiles available for movement
func get_available_targets() -> Dictionary:
	# Get variables
	var unit : Unit = _game_manager.get_mouse_selection()
	var tile_matrix = _game_manager.get_tile_matrix()
	
	# Check if the unit belongs to the player
	if unit.get_player_owner_id() != multiplayer.get_unique_id(): 
		MouseModeManager.set_mouse_mode(MouseModeManager.MOUSE_MODE.INSPECTION)
		return {"tiles" : [], "costs" : []}
	
	# Do a pathfinding call and save results
	var tiles_and_costs = PathFinding.get_reachable_tiles(tile_matrix, unit)
	available_tiles = tiles_and_costs["tiles"]
	
	# Highlight targets
	super._highlight_tiles(available_tiles)
	
	# Return results for visualization
	return tiles_and_costs

func perform_action(target):
	# Get variables
	var unit = _game_manager.get_mouse_selection()
	var tile_matrix = _game_manager.get_tile_matrix()
	
	# Do a pathfinding call
	var path : Array = PathFinding.find_path(tile_matrix, unit, target.get_matrix_position(), available_tiles)
	
	# Discard the initial tile if present
	if path.size() > 0: path.remove_at(0)
	
	# Here any checks if the path is inside any enemy zones of control would happen
	
	# Move the unit on the server
	rpc("_move_unit", unit.get_path(), path, multiplayer.get_unique_id())

# Remote Procedure Calls
# --------------------

@rpc("any_peer", "call_local")
func _move_unit(path_to_unit : NodePath, route : Array, caller_id : int):
	var tile_matrix : Array = _game_manager.get_tile_matrix()
	
	if path_to_unit == null: return
	if route == null: return

	# Get the unit
	var unit = get_node(path_to_unit)
	if unit == null: return
	
	# Here would be required logic for playing animations and moving the unit
	# At the moment just snap the unit at it's final destination
	
	var final_dest = route.pop_back()
	route.append(final_dest)
	
	if final_dest == null: return
	
	# Delete the unit from previous tile
	var previous_pos : Vector3 = unit.get_matrix_tile_position()
	tile_matrix[previous_pos.x][previous_pos.z].remove_unit_from_tile(unit)

	# Move the unit
	unit.position = tile_matrix[final_dest.x][final_dest.z].position
	tile_matrix[final_dest.x][final_dest.z].add_unit_to_tile(unit)
	unit.set_matrix_tile_position(final_dest)
	
	# Offset action points
	var route_cost = PathFinding.get_path_cost(tile_matrix, route)
	unit.offset_action_points(-route_cost)
	
	# Trigger a function for further cleanup in game manager
	var _stay_in_action = unit.get_action_points_left() > 0
	super.on_action_finished(true, caller_id)

# Getters
# --------------------
static func get_internal_name() -> String:
	return "Action_Move"
