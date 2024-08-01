extends Node

class_name GridTile

# Attributes
var type : int
var player_owner : int
var can_spawn : bool
var point_value : float
var units_in_tile = []	# Declare as unit class later

# Constructor
func _init(type_arg : int = -2, player_owner_arg = -1, can_spawn_arg = false, point_value_arg = -1, units_in_tile_arg = []):
	self.type = type_arg
	self.player_owner = player_owner_arg
	self.can_spawn = can_spawn_arg
	self.point_value = point_value_arg
	self.units_in_tile = units_in_tile_arg
