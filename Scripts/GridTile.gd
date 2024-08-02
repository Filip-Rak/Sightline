extends Node3D

class_name GridTile

# Attributes
# --------------------

enum TileType{
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
@export_enum("Default", "Water", "Forest", "Mountain", "Hill", "Town", "River", "Bridge") var type : int = 0
@export var point_value : int = 1
@export var player_owner_id : int = -1
@export var can_spawn : bool = false

# Gamepplay variables
var units_in_tile : Array
var support_calls : Array

# Type-specific properties and scenes
# "Default", "Water", "Forest", "Mountain", "Hill", "Town", "River", "Bridge"
var los_block = [false, false, true, true, false, true, false, false]
var mod_def = [1.0, 0.6, 1.3, 1.5, 1.1, 1.5, 1.3, 0.8]
var bonus_range = [0, 0, 0, 1, 1, 0, 0, 0]
var acces_to = [
	["placeholder", "all units"], 
	["placeholder", "IFV"], 
	["placeholder", "all units"], 
	["placeholder"], 
	["placeholder", "all units"], 
	["placeholder", "infantry"], 
	["placeholder", "all units"], 
	["placeholder", "all units"]]

func _ready():
	pass

# Getters
func blocks_line_of_sight() -> bool:
	return los_block[type]
	
func defense_modifier() -> float:
	return mod_def[type]
	
func range_bonus() -> int:
	return bonus_range[type]
	
func accesible_to() -> Array:
	return acces_to[type]
