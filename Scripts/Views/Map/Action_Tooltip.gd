extends PanelContainer

class_name Action_Tooltip

# Attributes
# --------------------
@export var _display_name_label : Label
@export var _description_label : RichTextLabel
@export var _vbox : VBoxContainer

# Public Methods
# --------------------
func set_up_tooltip(display_name : String, description : String):
	# Set up properties
	_display_name_label.text = display_name
	_description_label.bbcode_text = "[fill]" + description + "[/fill]"

# In the fucture this function could accept two types of string
# One would be the 'stat', the other value
# Making two labels instead of one, would allow for color coding
func add_label(text : String):
	var label : RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.bbcode_text = text
	label.fit_content = true
	_vbox.add_child(label)
