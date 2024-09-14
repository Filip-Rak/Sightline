extends Node3D

class_name Tile

# Exported settings
@export var _type : Tile_Properties.tile_type = Tile_Properties.tile_type.DEFAULT
@export var _tile_label : Tile_Label_3D
@export var _point_value : int = 0
@export var _team_id : int = -1
@export var _is_a_spawn : bool = false

# Gamepplay variables
var _matrix_position : Vector3
var _units_in_tile : Array
var _support_calls : Array
var _ap_stacking_mod : float = 1
var _he_stacking_mod : float = 1

const _ap_stacking_min : float = 0.5
const _he_stacking_min : float = 0.5
const _ap_stacking_conversion : float = 0.1
const _he_stacking_conversion : float = 0.1

# Ready Functions
func _ready():
	# Signals
	add_user_signal("tile_data_changed")
	
	# Tile label
	if _tile_label:
		_tile_label.update_info_label(_point_value, _team_id)

# Public Methods
# --------------------
func add_unit_to_tile(unit : Unit):
	# Update Array
	_units_in_tile.append(unit)
	
	# Get new team_id
	var new_id = PlayerManager.get_team_id(unit.get_player_owner_id())
	
	if new_id != _team_id:
		# Change ownership
		TeamManager.change_tile_owner(_matrix_position, _team_id, new_id)
		_team_id = new_id
		
		# Disable the spawn
		_is_a_spawn = false
	
	# Add unit's modifiers to the pool
	_update_stacking_mod()
	
	# Update the label above tile
	if _tile_label:
		_tile_label.update_label(_units_in_tile)
		_tile_label.update_info_label(_point_value, _team_id)
	else:
		printerr ("ERROR: Tile.gd -> add_unit_to_tile(): _tile_label not set!")
		
	emit_signal("tile_data_changed")

func remove_unit_from_tile(unit : Unit):
	# Make sure the onit is in the tile
	var array_pos = _units_in_tile.find(unit)
	if array_pos == -1: return
	
	# Update Array
	_units_in_tile.remove_at(array_pos)
	
	# Substract unit's modifiers from the pool
	_update_stacking_mod()
	
	# Update the label above tile
	if _tile_label:
		_tile_label.update_label(_units_in_tile)
		_tile_label.update_info_label(_point_value, _team_id)
	else:
		printerr ("ERROR: Tile.gd -> remove_unit_from_tile(): _tile_label not set!")
	
	emit_signal("tile_data_changed")

func has_enemy():
	for unit in _units_in_tile:
		if PlayerManager.get_team_id(unit.get_player_owner_id()) != PlayerManager.get_my_team_id():
			return true
			
	return false
	
# Private Methods
# --------------------
func _update_stacking_mod():
	var new_ap_mod : float = 1
	var new_he_mod : float = 1
	
	if _units_in_tile.size() >= 2:
		for unit in _units_in_tile:
			new_ap_mod -= (1 - Unit_Properties.get_ap_mod(unit.get_type())) * _ap_stacking_conversion
			new_he_mod -= (1 - Unit_Properties.get_he_mod(unit.get_type())) * _he_stacking_conversion
	
	_ap_stacking_mod = clamp(new_ap_mod, _ap_stacking_min, 1)
	_he_stacking_mod = clamp(new_he_mod, _he_stacking_min, 1)
	
# Setters
# --------------------
func set_matrix_position(pos : Vector3):
	_matrix_position = Vector3(pos.x, 0, pos.z)

# Getters
# --------------------
func get_type() -> Tile_Properties.tile_type:
	return _type

func get_team_id() -> int:
	return _team_id
	
func get_point_value() -> float:
	return _point_value
	
func get_is_a_spawn() -> bool:
	return _is_a_spawn
	
func get_matrix_position() -> Vector3:
	return _matrix_position

func get_units_in_tile() -> Array:
	return _units_in_tile

func get_support_calls() -> Array:
	return _support_calls

func get_ap_stacking_mod() -> float:
	return _ap_stacking_mod

func get_he_stacking_mod() -> float:
	return _he_stacking_mod
