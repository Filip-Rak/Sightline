extends Node3D

class_name Unit

# Attributes
# --------------------

# Exported settings
@export var _type : Unit_Properties.unit_type = Unit_Properties.unit_type.IMV

# Instance
var _action_points_left : int
var _hit_points_left : float
var _matrix_tile_position : Vector3
var _player_owner_id : int
var _transported_unit : Unit

# Ready Functions
# --------------------
func _ready():
	_action_points_left = Unit_Properties.get_action_points_max(_type)
	_hit_points_left = Unit_Properties.get_hit_points_max(_type)

# Public Methods
# --------------------

# Returns 'true' if action_points are left
func offset_action_points(offset : int) -> bool:
	_action_points_left += offset
	return _action_points_left > 0

# Returns 'true' if hp is above 0, 'false' if below or equal 0
func offset_hit_points(offset : float) -> bool:
	_hit_points_left += offset
	return _hit_points_left > 0
	
# Sets action points to the value in Unit_Properties
func reset_action_points():
	_action_points_left = Unit_Properties.get_action_points_max(_type)

# Getters
# --------------------
func get_type() -> Unit_Properties.unit_type:
	return _type

func get_action_points_left() -> int: 
	return _action_points_left

func get_hit_points_left() -> float: 
	return _hit_points_left

func get_matrix_tile_position() -> Vector3: 
	return _matrix_tile_position

func get_player_owner_id() -> int: 
	return _player_owner_id

func get_transported_unit() -> Unit: 
	return _transported_unit

# Setters
# --------------------
func set_player_owner(id : int): 
	_player_owner_id = id
	
# Remember to put y on 0!
func set_matrix_tile_position(new_position : Vector3): 
	_matrix_tile_position = Vector3(new_position.x, 0, new_position.z)

