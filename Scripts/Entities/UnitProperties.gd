extends Node

class_name Unit_Properties

# Categories
enum unit_category{
	INFANTRY,
	VEHICLE
}

static var _category_properties = {
	unit_category.INFANTRY:
		{
			"display_name": "Infantry",
		},
		unit_category.VEHICLE:
		{
			"display_name": "Vehicles",
		},
}

# Type-specific properties
enum unit_type{
	MOTOSTRELKI,
	PANZERGRENADIERS,
	HMMWV,
	M2A3,
	BMP2
}

static var _type_properties = {
	unit_type.MOTOSTRELKI: 
	{ 
		"display_name": "Motostrelki",
		"category" : unit_category.INFANTRY,
		"action_points": 1,
		"sight_range": 3,
		"hit_points_max": 100,
		"he_resistance" : 0.0,
		"ap_resistance" : 0.9,
		"can_be_transported": true,
		"scene": preload("res://Assets/Units/player_unit_infantry.tscn"),
		"actions" : [
				Action_Spawn.new(1, 5),
				Action_Move.new(
					"Walk",
					"Motostrelki march across the battlefield, bracing themselves for next assault."
				),
				Action_Range_Attack.new(
					"Suppresive Fire", 
					"Motostrelki fire a barrage of 7.62mm rounds, maintaining pressure on the enemy.", 
					1, 1, 5, 30, -1, false
				),
					Action_Range_Attack.new(
					"RPG Vystrel", 
					"Motostrelki fire a light RPG-18 anti-tank rocket. Effective at close range but lacking the punch to deal with heavy armor.", 
					1, 1, 25, 5, -1, false
				)
			]
	},
	unit_type.PANZERGRENADIERS: 
	{ 
		"display_name": "Panzergrenadiers",
		"category" : unit_category.INFANTRY,
		"action_points": 1,
		"sight_range": 3,
		"hit_points_max": 100,
		"he_resistance" : 0.0,
		"ap_resistance" : 0.9,
		"can_be_transported": true,
		"scene": preload("res://Assets/Units/player_unit_AT_infantry.tscn"),
		"actions" : [
				Action_Spawn.new(2, 2),
				Action_Move.new(
					"Advance",
					"Panzergrenadiers execute a coordinated advance, preparing to combat with hostile armored elements."
				),
				Action_Range_Attack.new(
					"Suppresive Fire", 
					"Panzergrenadiers unleash precise and controlled fire from their G36 rifles, leveraging their superior training and coordination.", 
					1, 1, 5, 20, -1, false
				),
				Action_Range_Attack.new(
					"PzF 3 Fire", 
					"Deploying the formidable Panzerfaust 3, Panzergrenadiers launch an anti-tank rocket, capable of punching through even well-armored vehicles.", 
					1, 1, 60, 15, -1, false
				),
				Action_Range_Attack.new(
					"Milan Strike", 
					"Panzergrenadiers fire a Milan anti-tank missile, capable of engaging targets at longer range but with lower destructive potential.", 
					3, 1, 30, 20
				),
			]
	},
	unit_type.HMMWV: 
	{ 
		"display_name": "HMMWV",
		"category" : unit_category.VEHICLE,
		"action_points": 3,
		"sight_range": 1,
		"hit_points_max": 100,
		"he_resistance" : 0.5,
		"ap_resistance" : 0.0,
		"can_be_transported": false,
		"scene": preload("res://Assets/Units/player_unit_IMV.tscn"),
		"actions" : [
				Action_Spawn.new(2, 2),
				Action_Move.new(
					"Fast Move",
					"The HMMWV speeds across the terrain, deploying swiftly to key locations."
				),
				Action_Range_Attack.new(
					"Suppresive Fire", 
					"The HMMWV's mounted M2 Browning machine gun rakes the enemy position with 50 cal. rounds, providing suppressive fire over longer ranges.", 
					2, 1, 10, 25
				)
			]
	},
	unit_type.M2A3: 
	{ 
		"display_name": "M2A3 Bradley IFV",
		"category" : unit_category.VEHICLE,
		"action_points": 2,
		"sight_range": 2,
		"hit_points_max": 100,
		"he_resistance" : 0.9,
		"ap_resistance" : 0.0,
		"can_be_transported": false,
		"scene": preload("res://Assets/Units/player_unit_IFV.tscn"),
		"actions" : [
				Action_Spawn.new(5, 1, 2),
				Action_Move.new(
					"Move Up",
					"The Bradley IFV moves up to provide fire support against infantry and armored elements alike."
				),
				Action_Range_Attack.new
				(
					"Bushmaster Burst", 
					"The Bradley's M242 Bushmaster autocannon unleashes a stream of 25mm rounds, tearing through infantry and light vehicles with deadly precision.", 
					3, 1, 40, 35
				)
			]
	},	
	unit_type.BMP2: 
	{ 
		"display_name": "BMP-2",
		"category" : unit_category.VEHICLE,
		"action_points": 2,
		"sight_range": 2,
		"hit_points_max": 60,
		"he_resistance" : 0.7,
		"ap_resistance" : 0.0,
		"can_be_transported": false,
		"scene": preload("res://Assets/Units/player_unit_BMP.tscn"),
		"actions" : [
				Action_Spawn.new(3, 1, 2),
				Action_Move.new(
					"Advance",
					"The BMP-2 moves into position, offering mobility and light firepower support for infantry."
				),
				Action_Range_Attack.new
				(
					"2A42 Burst", 
					"The BMP-2's 30mm 2A42 autocannon fires a rapid burst of armor-piercing and high-explosive rounds, effective against infantry and lightly armored vehicles.", 
					2, 1, 40, 25
				)
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

static func get_ap_resistance(u_type : unit_type) -> float:
	return _type_properties[u_type]["ap_resistance"]
	
static func get_he_resistance(u_type : unit_type) -> float:
	return _type_properties[u_type]["he_resistance"]

static func get_unit_category(u_type : unit_type) -> unit_category:
	return _type_properties[u_type]["category"]

static func get_cat_display_name(c_type : unit_category) -> String:
	return _category_properties[c_type]["display_name"]

# For all types
static func get_spawnable_units_of_category(category : unit_category) -> Array:
	var units : Array = []
	
	for u_type in get_spawnable_types():
		if _type_properties[u_type]["category"] == category:
			units.append(u_type)
			
	return units

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
	
