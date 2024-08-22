extends Node3D

class_name Action

# Attributes
# --------------------

# Other scripts
var _game_manager : Game_Manager

# Visual
var _display_name : String = "action_base_class_display_name"
var _description : String = "action_base_class_description_name"

# Stats
var _ap_cost : int
var _usage_limit : int
var _cooldown : int

# Instance specific
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
	self._cooldown_left = 0

# Protected Methods 
# --------------------

# For highlighting tiles
# Logic has been moved here from GameManager to allow for more custom highlighting
func _highlight_tiles(tiles : Array):
	# Clear previous highlighting
	_game_manager.highlight_manager.clear_mass_highlight()
	
	# Highlight new tiles
	_game_manager.highlight_manager.mass_highlight_tiles(tiles)

func _highlight_units():
	pass

func on_action_finished(stay_in_action : bool):
	# Recalculate the highlighting for other players
	if stay_in_action:
		# Redo the calculations to check now available targets
		_game_manager.select_action(_game_manager.selected_action)
	else:
		MouseModeManager.set_mouse_mode(MouseModeManager.MOUSE_MODE.INSPECTION)
		_game_manager.highlight_manager.clear_mouse_over_highlight()
		_game_manager.highlight_manager.clear_mass_highlight()
	
	# Recalculate the highlighting for other players
	_game_manager.highlight_manager.redo_highlighting(_game_manager.player_turn)

# Public Methods 
# --------------------

# Returns entities which can be targeted by the action
func get_available_targets() -> Dictionary:
	print ("ERROR: get_available_targets called on base class")
	return {}

# Checks if the action can be done on selected target and returns 'true' if succeeds 
func perform_action(_target):
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

static func get_internal_name() -> String:
	return "Action"

# Unit isntance
func get_uses_left() -> int:
	return _uses_left
	
func get_cooldown_left() -> int:
	return _cooldown_left

# Setters
# --------------------
func set_game_manager(gm : Game_Manager):
	_game_manager = gm
