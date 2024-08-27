extends Node3D

class_name Unit

# Attributes
# --------------------

# Exported settings
@export var _type : Unit_Properties.unit_type = Unit_Properties.unit_type.IMV
@export var _unit_label : Unit_Label_3D
@export var _visual_element : Node3D
@export var _collision_shape : CollisionShape3D

# Instance
var _action_points_left : int
var _hit_points_left : float
var _matrix_tile_position : Vector3
var _player_owner_id : int
var _transported_unit : Unit

# Ready Functions
# --------------------
func _ready():
	_action_points_left = Unit_Properties.get_action_points_max(_type)
	_hit_points_left = Unit_Properties.get_hit_points_max(_type)
	if _unit_label:
		_unit_label._unit_label_content.set_and_update(self, _unit_label)
		_unit_label.force_update_viewport_size()
	else:
		printerr("Unit.gd -> _ready(): No unit label assigned!")

# Public Methods
# --------------------

# Returns 'true' if action_points are left
func offset_action_points(offset : int) -> bool:
	# Update value
	_action_points_left += offset
	
	# Update UI
	if _unit_label: 
		_unit_label.update_all(self)
		
	return _action_points_left > 0

# Returns 'true' if hp is above 0, 'false' if below or equal 0
func offset_hit_points(offset : float) -> bool:
	# Update value
	_hit_points_left += offset
	
	# Update UI
	if _unit_label: 
		_unit_label.update_all(self)
		
	return _hit_points_left > 0
	
# Sets action points to the value in Unit_Properties
func reset_action_points():
	# Update value
	_action_points_left = Unit_Properties.get_action_points_max(_type)
	
	# Update UI
	if _unit_label: 
		_unit_label.update_all(self)

# Getters
# --------------------
func get_type() -> Unit_Properties.unit_type:
	return _type

func get_action_points_left() -> int: 
	return _action_points_left

func get_hit_points_left() -> float: 
	return _hit_points_left

func get_matrix_tile_position() -> Vector3: 
	return _matrix_tile_position

func get_player_owner_id() -> int: 
	return _player_owner_id

func get_transported_unit() -> Unit: 
	return _transported_unit

func get_label_conent() -> Unit_Label_Content:
	if _unit_label:
		return _unit_label.get_content()
	else:
		return null

# Setters
# --------------------
func set_player_owner(id : int): 
	_player_owner_id = id
	
# Remember to put y on 0!
func set_matrix_tile_position(new_position : Vector3): 
	_matrix_tile_position = Vector3(new_position.x, 0, new_position.z)

func enable_visual_elements(value : bool):
	if !_unit_label || !_visual_element:
		printerr ("ERROR: Unit.gd -> enable_visual_elements(). Not assigned exports")
		return
	
	if value:
		_unit_label.get_content().set_sprite_3D(_unit_label)
		_unit_label.add_child_content()
	else:
		_unit_label.remove_child_content()
		
	_visual_element.visible = value
	_collision_shape.disabled = !value
