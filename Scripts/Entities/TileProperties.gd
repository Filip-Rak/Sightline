extends Node

class_name Tile_Properties

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

# Dictionaries for type-specific properties and scenes
static var _type_properties = {
	tile_type.DEFAULT: 
	{ 
		"blocks_line_of_sight": false,
		"defense_modifier" : 1,
		"range_bonus": 0,
		"movement_cost" : 1,
		"accesible_to": [
			Unit_Properties.unit_type.INFANTRY,
			Unit_Properties.unit_type.AT_INFANTRY,
			Unit_Properties.unit_type.IMV,
			Unit_Properties.unit_type.IFV,
			]
	},
	tile_type.WATER: 
	{ 
		"blocks_line_of_sight": false,
		"defense_modifier" : 1.2,
		"range_bonus": 1,
		"movement_cost" : 3,
		"accesible_to": [
			Unit_Properties.unit_type.IFV,
			]
	},
	tile_type.FOREST: 
	{ 
		"blocks_line_of_sight": true,
		"defense_modifier" : 0.6,
		"range_bonus": 0,
		"movement_cost" : 3,
		"accesible_to": [
			Unit_Properties.unit_type.INFANTRY,
			Unit_Properties.unit_type.AT_INFANTRY,
			Unit_Properties.unit_type.IMV,
			Unit_Properties.unit_type.IFV,
			]
	},
	tile_type.MOUNTAIN: 
	{ 
		"blocks_line_of_sight": true,
		"defense_modifier" : 0.8,
		"range_bonus": 1,
		"movement_cost" : 3,
		"accesible_to": [
			
			]
	},
	tile_type.HILL: 
	{ 
		"blocks_line_of_sight": true,
		"defense_modifier" : 1,
		"range_bonus": 1,
		"movement_cost" : 1,
		"accesible_to": [
			Unit_Properties.unit_type.INFANTRY,
			Unit_Properties.unit_type.AT_INFANTRY,
			Unit_Properties.unit_type.IMV,
			Unit_Properties.unit_type.IFV,
			]
	},
	tile_type.TOWN: 
	{ 
		"blocks_line_of_sight": true,
		"defense_modifier" : 0.4,
		"range_bonus": 1,
		"movement_cost" : 2,
		"accesible_to": [
			Unit_Properties.unit_type.INFANTRY,
			Unit_Properties.unit_type.AT_INFANTRY,
			Unit_Properties.unit_type.IMV,
			Unit_Properties.unit_type.IFV,
			]
	},		
	tile_type.RIVER: 
	{ 
		"blocks_line_of_sight": false,
		"defense_modifier" : 0.8,
		"range_bonus": 0,
		"movement_cost" : 3,
		"accesible_to": [
			Unit_Properties.unit_type.IFV,
			]
	},		
	tile_type.BRIDGE: 
	{ 
		"blocks_line_of_sight": false,
		"defense_modifier" : 0.8,
		"range_bonus": 0,
		"movement_cost" : 1,
		"accesible_to": [
			Unit_Properties.unit_type.INFANTRY,
			Unit_Properties.unit_type.AT_INFANTRY,
			Unit_Properties.unit_type.IMV,
			Unit_Properties.unit_type.IFV,
			]
	},
}

# Type Specific Getters
# --------------------
static func get_blocks_line_of_sight(type : tile_type) -> bool:
	return _type_properties[type]["blocks_line_of_sight"]
	
static func get_accesible_to(type : tile_type) -> Array:
	return _type_properties[type]["accesible_to"]
	
static func is_accesible_to(tile : tile_type, unit : Unit_Properties.unit_type) -> bool:
	var accesible_to : Array = _type_properties[tile]["accesible_to"]
	if accesible_to.find(unit) != -1:
		return true
	else:
		return false
	
static func get_defense_modifier(type : tile_type) -> float:
	return _type_properties[type]["defense_modifier"]
	
static func get_range_bonus(type : tile_type) -> int:
	return _type_properties[type]["range_bonus"]
	
static func get_movement_cost(type : tile_type) -> int:
	return _type_properties[type]["movement_cost"] 

