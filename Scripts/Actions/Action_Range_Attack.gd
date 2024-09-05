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

var _available_tiles : Array

# Constructor
# --------------------
func _init(display_name : String, description : String, attack_range : int, attack_min_range : int, ap_damage : float, he_damage : float, ap_cost : int = -1, respects_LOS : bool = true, needs_spot : bool = true):
	# Super class
	self._display_name = display_name
	self._description = description
	self._ap_cost = ap_cost
	self._usage_limit = 0
	self._cooldown = 0
	self._starts_on_cooldown = false
	self._uses_left = 0
	
	# Child class
	_attack_range = attack_range
	_attack_min_range = attack_min_range
	_ap_damage = ap_damage
	_he_damage = he_damage
	_respects_LOS = respects_LOS
	_needs_spot = needs_spot

# Public Methods
# --------------------

# Returns tiles available for attack
func get_available_targets() -> Dictionary:
	# Get variables
	var unit : Unit = _game_manager.get_mouse_selection()
	var tile_matrix = _game_manager.get_tile_matrix()
	
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

