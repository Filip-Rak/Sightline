extends Node3D

class_name Action

# Attributes
# --------------------

# Constant variables
var _display_name : String
var _description : String
var _ap_cost : int
var _usage_limit : int
var _cooldown : int

# Unit isntance
var _uses_left : int
var _cooldown_left : int

# Constructor
# --------------------
func _init(display_name : String, description : String, ap_cost : int, usage_limit : int, cooldown : int):
	# Constants
	self._display_name = display_name
	self._description = description
	self._ap_cost = ap_cost
	self._usage_limit = usage_limit
	self._cooldown = cooldown
	
	# Unit isntance
	self._uses_left = usage_limit
	self._cooldown_left = cooldown

# Public Methods 
# --------------------

# Returns entities which can be targeted by the action
func get_available_targets(_unit, _tile_matrix : Array) -> Dictionary:
	print ("ERROR: get_available_targets called on base class")
	return {}

# Checks if the action can be done on selected target and returns 'true' if succeeds 
func perform_action(_unit, _target, _tile_matrix : Array):
	print ("ERROR: perform_action called on base class")
	return false

# Getters
# --------------------

# Constants
func get_display_name() -> String:
	return _display_name
	
func get_description() -> String:
	return _description
	
func get_ap_cost() -> int:
	return _ap_cost
	
func get_usage_limit() -> int:
	return _usage_limit

func get_cooldown() -> int:
	return _cooldown
	
# Unit isntance
func get_uses_left() -> int:
	return _uses_left
	
func get_cooldown_left() -> int:
	return _cooldown_left
