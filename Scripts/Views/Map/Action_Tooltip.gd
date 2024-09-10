extends PanelContainer

class_name Action_Tooltip

# Attributes
# --------------------
@export var _display_name_label : Label
@export var _description_label : RichTextLabel

# Public Methods
# --------------------
func set_up_tooltip(display_name : String, description : String):
	# Set up properties
	_display_name_label.text = display_name
	_description_label.text = description
