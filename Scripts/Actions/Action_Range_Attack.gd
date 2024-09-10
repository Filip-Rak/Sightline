extends Action

class_name Action_Range_Attack

# Attributes
# --------------------

# Gameplay
var _attack_range : int
var _attack_min_range : int
var _ap_damage : float
var _he_damage : float
var _respects_LOS : bool
var _needs_spot : bool
var _ap_required : bool

var _available_tiles : Array

# Constructor
# --------------------
func _init(display_name : String, description : String, attack_range : int, attack_min_range : int, ap_damage : float, he_damage : float, ap_cost : int = -1, ap_required : bool = true, respects_LOS : bool = true, needs_spot : bool = true):
	# Super class
	super._init(display_name, description, ap_cost, 0, 0)

	# Child class
	_attack_range = attack_range
	_attack_min_range = attack_min_range
	_ap_damage = ap_damage
	_he_damage = he_damage
	_respects_LOS = respects_LOS
	_needs_spot = needs_spot
	self._ap_required = ap_required

# Public Methods
# --------------------

# Returns tiles available for attack
func get_available_targets() -> Dictionary:
	# Get variables
	var unit : Unit = _game_manager.get_mouse_selection()
	var tile_matrix = _game_manager.get_tile_matrix()
	
	# Run checks
	if !unit.get_can_attack(): return {"tiles" : [], "costs" : []}
	if _ap_required && unit.get_action_points_left() <= 0: return {"tiles" : [], "costs" : []}
	
	# Check if the unit belongs to the player
	if unit.get_player_owner_id() != multiplayer.get_unique_id(): 
		MouseModeManager.set_mouse_mode(MouseModeManager.MOUSE_MODE.INSPECTION)
		return {"tiles" : [], "costs" : []}
	
	# Get tiles within range
	_available_tiles = _get_tiles_in_range(unit.get_matrix_tile_position(), tile_matrix)
	if _needs_spot: _filter_enemies(_available_tiles)
	if _respects_LOS: _filter_LOS(unit.get_matrix_tile_position(), _available_tiles, tile_matrix)
	
	# Highlight targets
	super._highlight_tiles(_available_tiles)
	
	# Return results for visualization
	return {"tiles" : _available_tiles, "costs" : []}

func perform_action(target : Tile):
	if !target is Tile: return
	
	# Get variables
	var unit : Unit = _game_manager.get_mouse_selection()
		
	# Make sure the selected target is within legal targets
	if _available_tiles.find(target) == -1: return
	
	# Handle cooldowns here
		
	# Apply attack on the net
	var defense_modifier = Tile_Properties.get_defense_modifier(target.get_type())
	rpc("apply_attack", _ap_damage, _he_damage, target.get_path(), defense_modifier, unit.get_path())

# Private Methods
# --------------------
func _get_tiles_in_range(unit_pos: Vector3, tile_matrix: Array) -> Array:
	var tiles_in_range: Array = []
	var max_x = tile_matrix.size()
	var max_z = tile_matrix[0].size()

	# Iterate over the square area around the unit within the specified range.
	for x in range(unit_pos.x - _attack_range, unit_pos.x + _attack_range + 1):
		for z in range(unit_pos.z - _attack_range, unit_pos.z + _attack_range + 1):
			
			# Ensure we're within map boundaries.
			if x >= 0 and x < max_x and z >= 0 and z < max_z:
				
				# Calculate the distance in both directions.
				var dx = abs(x - unit_pos.x)
				var dz = abs(z - unit_pos.z)

				# Check if the tile is within the maximum range and outside the minimum range.
				if (dx <= _attack_range and dz <= _attack_range) and (dx >= _attack_min_range or dz >= _attack_min_range):
					# Add the tile to the list.
					tiles_in_range.append(tile_matrix[x][z])
	
	return tiles_in_range

# Deletes tiles without enemies from the array
func _filter_enemies(tiles : Array):
	var to_remove : Array = []
	
	for i in range(tiles.size()):
		if !tiles[i].has_enemy():
			to_remove.append(i)
			
	# Remove elements in reverse order
	for i in range(to_remove.size() - 1, -1, -1):
		tiles.remove_at(to_remove[i])

func _filter_LOS(unit_pos : Vector3, tiles : Array, tile_matrix : Array):
	var to_remove : Array = []
	
	for i in range(tiles.size()):
		if _is_line_of_sight_blocked(unit_pos, tiles[i].get_matrix_position(), tile_matrix) ||_is_line_of_sight_blocked(tiles[i].get_matrix_position(), unit_pos, tile_matrix):
			to_remove.append(i)
			
	# Remove elements in reverse order
	for i in range(to_remove.size() - 1, -1, -1):
		tiles.remove_at(to_remove[i])

func _is_line_of_sight_blocked(origin: Vector3, target: Vector3, tile_matrix: Array) -> bool:
	var start_x = int(origin.x)
	var start_z = int(origin.z)
	var end_x = int(target.x)
	var end_z = int(target.z)
	
	var dx = abs(end_x - start_x)
	var dz = abs(end_z - start_z)
	
	var sx = -1
	if start_x < end_x: sx = 1
	
	var sz = -1
	if start_z < end_z: sz = 1
	
	var err = dx - dz
	var current_x = start_x
	var current_z = start_z
	
	while true:
		# Move to the next tile in the line
		var e2 = err * 2
		if e2 > -dz:
			err -= dz
			current_x += sx
		if e2 < dx:
			err += dx
			current_z += sz
			
		# Check if we're about to reach the target tile (we stop right before the target)
		if current_x == end_x && current_z == end_z: break

		# Check if the current tile blocks line of sight
		if tile_matrix[current_x][current_z] && Tile_Properties.get_blocks_line_of_sight(tile_matrix[current_x][current_z].get_type()):
			return true
			
	return false

# Remote Procedure Calls
# --------------------
@rpc("any_peer", "call_local", "reliable")
func apply_attack(ap_damage : float, he_damage : float, target_tile_path : NodePath, defense_mod : float, attacker_path : NodePath):
	var attacker : Unit = get_node(attacker_path)
	var target_tile : Tile = get_node(target_tile_path)
	
	# Handle unit's action points
	# If set to -1 deplete them completely
	if _ap_cost <= -1:
		attacker.offset_action_points(-Unit_Properties.get_action_points_max(attacker.get_type()))
		attacker.set_can_attack(false)
	else:
		attacker.offset_action_points(-_ap_cost)
		if attacker.get_action_points_left() == 0: 
			attacker.set_can_attack(false)
	
	# Get stacking defense multipliers
	var bonus_he_resist : float = 0
	var bonus_ap_resist : float = 0
	
	for unit : Unit in target_tile.get_units_in_tile():
		bonus_he_resist += Unit_Properties.get_he_resistance(unit.get_type()) / 10
		bonus_ap_resist += Unit_Properties.get_ap_resistance(unit.get_type()) / 10
		
	# Clamp bonus defense modifier
	bonus_he_resist = clamp(bonus_he_resist, 0.0, 0.3)
	bonus_ap_resist = clamp(bonus_ap_resist, 0.0, 0.3)
	
	# Store units for destruction
	var units_to_destroy : Array = []
	
	# Calc damage
	var final_ap = ap_damage * (1 - bonus_ap_resist)
	var final_he = he_damage * (1 - bonus_he_resist)
	
	# Apply damage
	for unit : Unit in target_tile.get_units_in_tile():
		unit.offset_hit_points(final_ap, final_he, defense_mod)
		if unit.get_hit_points_left() <= 0:
			units_to_destroy.append(unit)
	
	# Destroy units
	for unit : Unit in units_to_destroy:
		unit.destroy_unit(_game_manager)
		
	# Trigger a function for further cleanup in game manager
	var _stay_in_action = attacker.get_action_points_left() > 0
	super.on_action_finished(attacker.get_can_attack(), multiplayer.get_unique_id(), false, false)
	
# Getters
# --------------------
static func get_internal_name() -> String:
	return "Action_Range_Attack"
