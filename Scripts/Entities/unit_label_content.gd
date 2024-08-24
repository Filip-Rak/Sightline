extends Control

class_name Unit_Label_Content

# Attributes
# --------------------

# References
@export var _action_points_label : Label
@export var _unit_name_label : Label
@export var _health_bar : ProgressBar
var _assigned_unit : Unit

# Unit properties
var ac_points_max : int

# Public Methods
# --------------------

# For initial set up of the elements
func set_and_update(unit : Unit):
	# Save unit reference
	_assigned_unit = unit
	
	# Health Bar
	_health_bar.min_value = 0
	_health_bar.max_value = Unit_Properties.get_hit_points_max(unit.get_type())
	
	# Name Label
	_unit_name_label.text = Unit_Properties.get_display_name(unit.get_type())
	
	# Action Points Label
	ac_points_max = Unit_Properties.get_action_points_max(unit.get_type())
	
	# Call the function for updating the values
	update_all_elements(unit)

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
	_action_points_label.text = str(left) + "/" + str(ac_points_max)
