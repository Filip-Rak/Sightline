extends Sprite3D

class_name Tile_Label_3D

# Attributes
# --------------------
@export var _unit_vbox : VBoxContainer
@export var _shared_unit_label : PanelContainer
@export var _unit_viewport : SubViewport
@export var _info_sprite : Sprite3D
@export var _info_label : Label
@export var _display_limit : int = 3

# Ready Function
# --------------------
func _ready():
	_unit_vbox.visible = false
	_shared_unit_label.visible = false

# Public Methods
# --------------------
func update_label(units : Array):
	if units.size() > _display_limit:
		_shared_unit_label.visible = true
		_unit_viewport.size = _shared_unit_label.size
		_set_unit_vbox(units)
		_unit_vbox.visible = false
	elif units.size() > 1:
		_set_unit_vbox(units)
		_unit_vbox.visible = true
		_shared_unit_label.visible = false
		_unit_viewport.size = _unit_vbox.size
	else:
		_clear_unit_vbox() 
		_shared_unit_label.visible = false
		_unit_vbox.visible = false
		
	# Make sure to redraw vbox for size updates to take place
	_unit_vbox.queue_redraw()

func update_info_label(points : int, team_id : int):
	# If the tile has no value
	if points <= 0: 
		_info_sprite.visible = false
		return 
	
	# If the tile has point value
	var text : String = "Value: %d" % points
	if team_id > 0: text += " | Team: %d" % team_id
	
	_info_label.text = text
	_info_sprite.visible = true

# Private Methods
# --------------------
func _clear_unit_vbox():
	# Clear the vbox from labels
	# And activate their parents labels
	for label : Unit_Label_Content in _unit_vbox.get_children():
		_unit_vbox.remove_child(label)
		label.owner = null
		label.get_unit().enable_visual_elements(true)

# Not most efficient but simplest 
# with higher chances of working under less predicitable cicumstances
func _set_unit_vbox(units : Array):
	# Clear vbox of labels
	_clear_unit_vbox()
	
	# For every unit
	for unit : Unit in units:
		# Get it's label and ensure it exists
		var label : Unit_Label_Content = unit.get_label_conent()
		if label != null:
			# Disable parent's 3D label
			unit.enable_visual_elements(false)
			
			# Add label to vbox
			label.owner = null
			label.set_sprite_3D(self)
			_unit_vbox.add_child(label)

# Input
func _unhandled_input(_event):
	if Input.is_action_just_pressed("main_interaction"):
		var local_pos = _unit_viewport.get_mouse_position()
		if local_pos != Vector2.ZERO:
			print ("INPUT: %s" % [local_pos])
		
		# Check which node in the VBox was clicked
		var clicked_node = find_node_under_click(local_pos)
		
		if clicked_node:
			print ("CLICKED ON %s" % [clicked_node])

func find_node_under_click(local_pos: Vector2) -> Control:
	# Iterate over all children of VBox to see which one was clicked
	for child in _unit_vbox.get_children():
		if child is Control:
			var rect = child.get_rect()
			if rect.has_point(local_pos):
				return child
	return null

