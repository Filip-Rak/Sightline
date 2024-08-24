extends Node

class_name Unit_Properties

# Type-specific properties
enum unit_type{
	INFANTRY,
	AT_INFANTRY,
	IMV,
	IFV
}

static var _type_properties = {
	unit_type.INFANTRY: 
	{ 
		"display_name": "Motostrelki",
		"price": 1.0,
		"action_points": 1,
		"sight_range": 3,
		"hit_points_max": 100,
		"can_be_transported": true,
		"scene": preload("res://Assets/Units/player_unit_infantry.tscn"),
		"actions" : [
				Action_Spawn.new(1, 5),
				Action_Move.new("INF MOVE")
			]
	},
	unit_type.AT_INFANTRY: 
	{ 
		"display_name": "Panzergrenadiers",
		"price": 2.0,
		"action_points": 1,
		"sight_range": 3,
		"hit_points_max": 80,
		"can_be_transported": true,
		"scene": preload("res://Assets/Units/player_unit_AT_infantry.tscn"),
		"actions" : [
				Action_Spawn.new(2, 2),
				Action_Move.new("AT MOVE")
			]
	},
	unit_type.IMV: 
	{ 
		"display_name": "HMMWV",
		"price": 2.0,
		"action_points": 3,
		"sight_range": 1,
		"hit_points_max": 40,
		"can_be_transported": false,
		"scene": preload("res://Assets/Units/player_unit_IMV.tscn"),
		"actions" : [
				Action_Spawn.new(2, 2),
				Action_Move.new("IMV MOVE")
			]
	},
	unit_type.IFV: 
	{ 
		"display_name": "M2A3 Bradley IFV",
		"price": 5.0,
		"action_points": 2,
		"sight_range": 2,
		"hit_points_max": 120,
		"can_be_transported": false,
		"scene": preload("res://Assets/Units/player_unit_IFV.tscn"),
		"actions" : [
				Action_Spawn.new(5, 1),
				Action_Move.new("IFV MOVE")
			]
	},
}

# Getters
# --------------------

# For a given type
static func get_scene_of_type(given_type : unit_type) -> PackedScene: 
	return _type_properties[given_type]["scene"]

static func get_actions(u_type : unit_type) -> Array: 
	return _type_properties[u_type]["actions"]

static func get_price(u_type : unit_type) -> float: 
	return _type_properties[u_type]["price"]

static func get_action_points_max(u_type : unit_type) -> int: 
	return _type_properties[u_type]["action_points"]

static func get_sight_range(u_type : unit_type) -> int: 
	return _type_properties[u_type]["sight_range"]

static func get_hit_points_max(u_type : unit_type) -> float: 
	return _type_properties[u_type]["hit_points_max"]

static func get_can_be_transported(u_type : unit_type) -> bool: 
	return _type_properties[u_type]["can_be_transported"]

static func get_scene(u_type : unit_type) -> PackedScene: 
	return _type_properties[u_type]["scene"]

static func get_action(u_type : unit_type, internal_name : String) -> Action:
	for ac in get_actions(u_type): 
		if ac.get_internal_name() == internal_name:
			return ac
			
	return null

static func get_display_name(u_type : unit_type) -> String:
	return _type_properties[u_type]["display_name"]

# For all types
static func get_spawnable_types() -> Array:
	var spawnable_types : Array = []
	
	for u_type in _type_properties:
		if get_action(u_type, Action_Spawn.get_internal_name()):
			spawnable_types.append(u_type)
			
	return spawnable_types

static func get_all_actions() -> Array:
	var all_actions : Array = []
	
	for unit_type_key in _type_properties.keys():
		var actions = _type_properties[unit_type_key].get("actions", [])
		for action in actions:
			# Check if action is not already in the list to avoid duplicates
			if action not in all_actions:
				all_actions.append(action)
		
	return all_actions
	
