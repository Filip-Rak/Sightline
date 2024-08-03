extends Node

class_name GridTile

# Attributes
# --------------------

enum tile_type{
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
@export var type : tile_type = tile_type.DEFAULT
@export var point_value : int = 1
@export var team_id : int = -1
@export var is_a_spawn : bool = false

# Gamepplay variables
var units_in_tile : Array
var support_calls : Array

# Dictionaries for type-specific properties and scenes
var type_properties = {
	tile_type.DEFAULT: 
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
	tile_type.WATER: 
	{ 
		"blocks_line_of_sight": false,
		"defense_modifier" : 0.6,
		"range_bonus": 1,
		"accesible_to": [
			PlayerUnit.unit_type.IFV,
			]
	},
	tile_type.FOREST: 
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
	tile_type.MOUNTAIN: 
	{ 
		"blocks_line_of_sight": true,
		"defense_modifier" : 1,
		"range_bonus": 1,
		"accesible_to": [
			
			]
	},
	tile_type.HILL: 
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
	tile_type.TOWN: 
	{ 
		"blocks_line_of_sight": true,
		"defense_modifier" : 1.5,
		"range_bonus": 1,
		"accesible_to": [
			PlayerUnit.unit_type.INFANTRY,
			PlayerUnit.unit_type.AT_INFANTRY,
			]
	},		
	tile_type.RIVER: 
	{ 
		"blocks_line_of_sight": false,
		"defense_modifier" : 1.4,
		"range_bonus": 0,
		"accesible_to": [
			PlayerUnit.unit_type.IFV,
			]
	},		
	tile_type.BRIDGE: 
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
func get_team_id():
	return team_id
	
func get_is_a_spawn():
	return is_a_spawn
