extends Node3D

class_name Action

# Attributes
# --------------------

# Other scripts
var _game_manager : Game_Manager
var _tooltip_instance : Action_Tooltip

# Visual
var _display_name : String = "action_base_class_display_name"
var _description : String = "action_base_class_description_name"

# Stats
var _ap_cost : int
var _usage_limit : int
var _cooldown : int
var _starts_on_cooldown : bool

# Instance specific
var _uses_left : int
var _last_use_turn : int

# Constructor
# --------------------
func _init(display_name : String, description : String, ap_cost : int, usage_limit : int, cooldown : int, starts_on_cooldown : bool = false):
	# Constants
	self._display_name = display_name
	self._description = description
	self._ap_cost = ap_cost
	self._usage_limit = usage_limit
	self._cooldown = cooldown
	self._starts_on_cooldown = starts_on_cooldown
	
	# Unit isntance
	self._uses_left = usage_limit
	if starts_on_cooldown:
		self._last_use_turn = 0
	else:
		_last_use_turn = -1000
		
	# Set up the tooltip
	_tooltip_instance = preload("res://Scenes/action_tooltip.tscn").instantiate()
	_tooltip_instance.set_up_tooltip(_display_name, _description)

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

func on_action_finished(stay_in_action : bool, caller_id : int, handle_cooldown : bool = true, recalc_highlight_for_others : bool = true):
	if stay_in_action:
		# Redo the calculations to check now available targets
		_game_manager.select_action(_game_manager.selected_action)
	else:
		MouseModeManager.set_mouse_mode(MouseModeManager.MOUSE_MODE.INSPECTION)
		_game_manager.highlight_manager.clear_mouse_over_highlight()
		_game_manager.highlight_manager.clear_mass_highlight()
	
	# Recalculate the highlighting for other players
	if recalc_highlight_for_others:
		_game_manager.highlight_manager.redo_highlighting(_game_manager.player_turn)
	
	# Update propterties of the action for the caller
	if handle_cooldown && multiplayer.get_unique_id() == caller_id:
		_last_use_turn = _game_manager.turn_manager.get_turn_num()
		_usage_limit -= 1

# Public Methods 
# --------------------

# Returns entities which can be targeted by the action
func get_available_targets() -> Dictionary:
	print ("ERROR: get_available_targets called on base class")
	return {}

# Checks if the action can be done on selected target and returns 'true' if succeeds 
func perform_action(_target):
	printerr("ERROR: perform_action called on base class")
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
	if !_game_manager: return 0
	if !_game_manager.turn_manager: return 0
	
	var cooldown_left = _cooldown - (_game_manager.turn_manager.get_turn_num() - _last_use_turn)
	if cooldown_left < 0: cooldown_left = 0
	
	return cooldown_left

# Setters
# --------------------
func set_game_manager(gm : Game_Manager):
	_game_manager = gm

# Getters
# --------------------
func get_tooltip_instance(_unit : Unit) -> Action_Tooltip:
	return _tooltip_instance
