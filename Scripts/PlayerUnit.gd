extends Node3D

class_name PlayerUnit

# Attributes
# --------------------

# Exported settings
@export var unit_type : UnitType = UnitType.IMV

# Gameplay variables
var action_points_left = type_properties[unit_type]["action_points"]
var hit_points_left = type_properties[unit_type]["hit_points_max"]
var tile_position : Vector3
var transported_unit : PlayerUnit

# Type-specific properties
enum UnitType{
	INFANTRY,
	AT_INFANTRY,
	IMV,
	IFV
}

var type_properties = {
	UnitType.INFANTRY: 
	{ 
		"price": 1.0,
		"action_points": 2,
		"sight_range": 3,
		"hit_points_max": 100,
		"can_transport": false,
		"can_be_transported": true,
		"attacks" : ["placeholder", "for", "attacks"]
	},
	UnitType.AT_INFANTRY: 
	{ 
		"price": 2.0,
		"action_points": 2,
		"sight_range": 3,
		"hit_points_max": 80,
		"can_transport": false,
		"can_be_transported": true,
		"attacks" : ["placeholder", "for", "attacks"]
	},
	UnitType.IMV: 
	{ 
		"price": 2.0,
		"action_points": 5,
		"sight_range": 1,
		"hit_points_max": 40,
		"can_transport": true,
		"can_be_transported": false,
		"attacks" : ["placeholder", "for", "attacks"]
	},
	UnitType.IFV: 
	{ 
		"price": 5.0,
		"action_points": 4,
		"sight_range": 2,
		"hit_points_max": 120,
		"can_transport": true,
		"can_be_transported": false,
		"attacks" : ["placeholder", "for", "attacks"]
	},
}

# Getters
# --------------------

func get_price() -> float: return type_properties[unit_type]["price"]
func get_action_points_max() -> int: return type_properties[unit_type]["action_points"]
func get_action_points_left() -> int: return action_points_left
func get_sight_range() -> int: return type_properties[unit_type]["sight_range"]
func get_hit_points_max() -> float: return type_properties[unit_type]["hit_points_max"]
func get_hit_points_left() -> float: return hit_points_left
func get_can_transport() -> bool: return type_properties[unit_type]["can_transport"]
func get_can_be_transported() -> bool: return type_properties[unit_type]["can_be_transported"]
func get_attacks() -> Array: return type_properties[unit_type]["attacks"]
func get_tile_position() -> Vector3: return tile_position
func get_transported_unit() -> PlayerUnit: return transported_unit

# Interactive Setters
# --------------------

# Returns 'true' if action_points are left
func offset_action_points(offset : float) -> bool:
	action_points_left -= offset
	return action_points_left > 0

# Returns 'true' if hp is above 0, 'false' if below or equal 0
func offset_hit_points(offset : float) -> bool:
	hit_points_left -= offset
	return hit_points_left > 0
	
# Returns 'false' if is either full or invalid unit is loaded
func load_transportable_unit(unit_to_load : PlayerUnit) -> bool:
	if !transported_unit && unit_to_load.get_can_be_transported():
		transported_unit = unit_to_load
		return true
	
	return false

# Setters
# --------------------

# Remember to put y on 0!
func set_tile_position(new_position : Vector3):
	tile_position = new_position
	
	
