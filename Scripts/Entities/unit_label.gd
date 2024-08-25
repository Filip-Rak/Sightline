extends Sprite3D

class_name Unit_Label

# Attributes
# --------------------

# External references
@export var _viewport : SubViewport
@export var _unit_label_content : Unit_Label_Content

# Ready Functions
# --------------------

func update_all(unit : Unit):
	if _unit_label_content == null:
		print ("ERROR: unit_label.gd -> update_all(): _unit_label_content not set!")
		return
	
	# Update the values in contents
	_unit_label_content.update_all_elements(unit)
	
	# Adjust the size of the 3D element
	_viewport.size = _unit_label_content.get_center_container().size

# Getters
# --------------------
func get_content() -> Unit_Label_Content:
	return _unit_label_content
