extends Sprite3D

class_name Unit_Label

# Attributes
# --------------------

# External references
@export var _unit_label_content : Unit_Label_Content

# Getters
# --------------------
func get_content() -> Unit_Label_Content:
	return _unit_label_content
