extends Node

class_name GridTile

# Attributes
# --------------------

enum TILE_TYPE{
	DEFAULT,
	WATER,
	FOREST,
	MOUNTAIN,
	HILL,
	TOWN,
	RIVER,
	BRIDGE
}

# Exported settings
@export var type : TILE_TYPE = TILE_TYPE.DEFAULT
@export var point_value : int = 1
@export var team_id : int = -1
@export var is_a_spawn : bool = false

# Gamepplay variables
var matrix_position : Vector3
var units_in_tile : Array
var support_calls : Array

# Dictionaries for type-specific properties and scenes
var type_properties = {
	TILE_TYPE.DEFAULT: 
	{ 
		"blocks_line_of_sight": false,
		"defense_modifier" : 1.0,
		"range_bonus": 0,
		"accesible_to": [
			PlayerUnit.unit_type.INFANTRY,
			PlayerUnit.unit_type.AT_INFANTRY,
			PlayerUnit.unit_type.IMV,
			PlayerUnit.unit_type.IFV,
			]
	},
	TILE_TYPE.WATER: 
	{ 
		"blocks_line_of_sight": false,
		"defense_modifier" : 0.6,
		"range_bonus": 1,
		"accesible_to": [
			PlayerUnit.unit_type.IFV,
			]
	},
	TILE_TYPE.FOREST: 
	{ 
		"blocks_line_of_sight": true,
		"defense_modifier" : 1.3,
		"range_bonus": 0,
		"accesible_to": [
			PlayerUnit.unit_type.INFANTRY,
			PlayerUnit.unit_type.AT_INFANTRY,
			PlayerUnit.unit_type.IMV,
			PlayerUnit.unit_type.IFV,
			]
	},
	TILE_TYPE.MOUNTAIN: 
	{ 
		"blocks_line_of_sight": true,
		"defense_modifier" : 1,
		"range_bonus": 1,
		"accesible_to": [
			
			]
	},
	TILE_TYPE.HILL: 
	{ 
		"blocks_line_of_sight": true,
		"defense_modifier" : 1.1,
		"range_bonus": 1,
		"accesible_to": [
			PlayerUnit.unit_type.INFANTRY,
			PlayerUnit.unit_type.AT_INFANTRY,
			PlayerUnit.unit_type.IMV,
			PlayerUnit.unit_type.IFV,
			]
	},
	TILE_TYPE.TOWN: 
	{ 
		"blocks_line_of_sight": true,
		"defense_modifier" : 1.5,
		"range_bonus": 1,
		"accesible_to": [
			PlayerUnit.unit_type.INFANTRY,
			PlayerUnit.unit_type.AT_INFANTRY,
			]
	},		
	TILE_TYPE.RIVER: 
	{ 
		"blocks_line_of_sight": false,
		"defense_modifier" : 1.4,
		"range_bonus": 0,
		"accesible_to": [
			PlayerUnit.unit_type.IFV,
			]
	},		
	TILE_TYPE.BRIDGE: 
	{ 
		"blocks_line_of_sight": false,
		"defense_modifier" : 1.1,
		"range_bonus": 0,
		"accesible_to": [
			PlayerUnit.unit_type.INFANTRY,
			PlayerUnit.unit_type.AT_INFANTRY,
			PlayerUnit.unit_type.IMV,
			PlayerUnit.unit_type.IFV,
			]
	},
}

func _ready():
	# print(blocks_line_of_sight())
	# print(accesible_to())
	# print(defense_modifier())
	# print(range_bonus())
	pass
	
# Setters
# --------------------

func set_matrix_position(pos : Vector3):
	matrix_position = Vector3(pos.x, 0, pos.z)

# Type Specific Getters
# --------------------
func get_blocks_line_of_sight() -> bool:
	return type_properties[type]["blocks_line_of_sight"]
	
func get_accesible_to() -> Array:
	return type_properties[type]["accesible_to"]
	
func get_defense_modifier() -> float:
	return type_properties[type]["defense_modifier"]
	
func get_range_bonus() -> int:
	return type_properties[type]["range_bonus"]

# Instance Specific Getters
# --------------------
func get_team_id() -> int:
	return team_id
	
func get_is_a_spawn() -> bool:
	return is_a_spawn
	
func get_matrix_position() -> Vector3:
	return matrix_position
