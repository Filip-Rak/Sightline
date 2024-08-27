extends Control

class_name Unit_Label_Content

# Attributes
# --------------------

# References
@export var _sprite3D : Sprite3D
@export var _action_points_label : Label
@export var _unit_name_label : Label
@export var _health_bar : ProgressBar
@export var _separator : VSeparator
@export var _delimiter : String = "/"
var _assigned_unit : Unit
var _initial_pos : Vector2

# Unit properties
var _ac_points_max : int

# Public Methods
# --------------------

# For initial set up of the elements
func set_and_update(unit : Unit, sprite3D : Sprite3D):
	# Save unit reference
	_assigned_unit = unit
	
	# Save sprite3D reference
	_sprite3D = sprite3D
	
	# Save initial positions
	_initial_pos = position
	
	# Health Bar
	_health_bar.min_value = 0
	_health_bar.max_value = Unit_Properties.get_hit_points_max(unit.get_type())
	
	# Name Label
	_unit_name_label.text = Unit_Properties.get_display_name(unit.get_type())
	
	# Action Points Label
	# If the unit is in our team, set up the label
	if PlayerManager.get_team_id(unit.get_player_owner_id()) == PlayerManager.get_my_team_id():
		_ac_points_max = Unit_Properties.get_action_points_max(unit.get_type())
	# If it's in the opposite team, disable the label
	else:
		_action_points_label.visible = false
		_separator.visible = false
	
	# Call the function for updating the values
	update_all_elements(unit)
	
	# Call the update on 3D when done
	# This class was suppoused to be standalone
	# And this is stupid, and dumb
	# And so is GDScript
	if _assigned_unit && _assigned_unit._unit_label:
		_assigned_unit._unit_label.force_update_viewport_size()

# Updates everything
func update_all_elements(unit : Unit):
	# Health Bar
	update_health_bar(unit.get_hit_points_left())
	
	# Action Points Label
	var ac_left = unit.get_action_points_left()
	update_action_points_label(ac_left)

func update_health_bar(value : float):
	_health_bar.value = value

func update_action_points_label(left : int):
	_action_points_label.text = str(left) + _delimiter + str(_ac_points_max)

func reset_pos():
	position = _initial_pos

# Getters
# --------------------
func get_unit() -> Unit:
	return _assigned_unit

# Setters
# --------------------
func set_sprite_3D(sprite : Sprite3D):
	_sprite3D = sprite

