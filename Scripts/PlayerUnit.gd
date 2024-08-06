extends Node3D

class_name PlayerUnit

# Attributes
# --------------------

# Exported settings
@export var type : unit_type = unit_type.IMV

# Instance
var action_points_left : int
var hit_points_left : float
var matrix_tile_position : Vector3
var player_owner_id : int
var transported_unit : PlayerUnit

# Type-specific properties
enum unit_type{
	INFANTRY,
	AT_INFANTRY,
	IMV,
	IFV
}

static var type_properties = {
	unit_type.INFANTRY: 
	{ 
		"price": 1.0,
		"action_points": 2,
		"sight_range": 3,
		"hit_points_max": 100,
		"can_transport": false,
		"can_be_transported": true,
		"scene": preload("res://Assets/Units/player_unit_infantry.tscn"),
		"attacks" : ["placeholder", "for", "attacks"]
	},
	unit_type.AT_INFANTRY: 
	{ 
		"price": 2.0,
		"action_points": 2,
		"sight_range": 3,
		"hit_points_max": 80,
		"can_transport": false,
		"can_be_transported": true,
		"scene": preload("res://Assets/Units/player_unit_AT_infantry.tscn"),
		"attacks" : ["placeholder", "for", "attacks"]
	},
	unit_type.IMV: 
	{ 
		"price": 2.0,
		"action_points": 5,
		"sight_range": 1,
		"hit_points_max": 40,
		"can_transport": true,
		"can_be_transported": false,
		"scene": preload("res://Assets/Units/player_unit_IMV.tscn"),
		"attacks" : ["placeholder", "for", "attacks"]
	},
	unit_type.IFV: 
	{ 
		"price": 5.0,
		"action_points": 4,
		"sight_range": 2,
		"hit_points_max": 120,
		"can_transport": true,
		"can_be_transported": false,
		"scene": preload("res://Assets/Units/player_unit_IFV.tscn"),
		"attacks" : ["placeholder", "for", "attacks"]
	},
}

# Ready Functions
func _ready():
	action_points_left = type_properties[type]["action_points"]
	hit_points_left = type_properties[type]["hit_points_max"]
	# print_all()


# Type Getters
# --------------------
func get_price() -> float: return type_properties[type]["price"]
func get_action_points_max() -> int: return type_properties[type]["action_points"]
func get_sight_range() -> int: return type_properties[type]["sight_range"]
func get_hit_points_max() -> float: return type_properties[type]["hit_points_max"]
func get_can_transport() -> bool: return type_properties[type]["can_transport"]
func get_can_be_transported() -> bool: return type_properties[type]["can_be_transported"]
func get_scene() -> PackedScene: return type_properties[type]["scene"]
static func get_scene_of_type(given_type : unit_type) -> PackedScene: return type_properties[given_type]["scene"]
func get_attacks() -> Array: return type_properties[type]["attacks"]

# Instance Getters
# --------------------

func get_action_points_left() -> int: return action_points_left
func get_hit_points_left() -> float: return hit_points_left
func get_matrix_tile_position() -> Vector3: return matrix_tile_position
func get_player_owner_id() -> int: return player_owner_id
func get_transported_unit() -> PlayerUnit: return transported_unit

# Interactive Setters
# --------------------

# Returns 'true' if action_points are left
func offset_action_points(offset : int) -> bool:
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
func set_matrix_tile_position(new_position : Vector3):
	matrix_tile_position = Vector3(new_position.x, 0, new_position.z)

func set_player_owner(id :int):
	player_owner_id = id
	
	
func print_all():
	print("get_price: " + str(get_price()))
	print("get_action_points_max: " + str(get_action_points_max()))
	print("get_sight_range: " + str(get_sight_range()))
	print("get_hit_points_max: " + str(get_hit_points_max()))
	print("get_can_transport: " + str(get_can_transport()))
	print("get_can_be_transported: " + str(get_can_be_transported()))
	print("get_attacks: " + str(get_attacks()))
	print("get_action_points_left: " + str(get_action_points_left()))
	print("get_hit_points_left: " + str(get_hit_points_left()))
	print("get_matrix_tile_position: " + str(get_matrix_tile_position()))
	print("get_transported_unit: " + str(get_transported_unit()))
	
	
	
	
