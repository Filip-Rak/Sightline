extends Node3D

class_name Unit

# Attributes
# --------------------

# Exported settings
@export var _type : Unit_Properties.unit_type = Unit_Properties.unit_type.values()[0]
@export var _unit_label : Unit_Label_3D
@export var _visual_element : Node3D
@export var _collision_shape : CollisionShape3D

# Instance
var _action_points_left : int
var _can_attack : bool
var _hit_points_left : float
var _matrix_tile_position : Vector3
var _player_owner_id : int
var _transported_unit : Unit

# [action_name] "last_use_turn" : int, "uses_left" : int
var _action_states : Dictionary = {}

# Constructor
# --------------------
func _init():
	# Signals
	add_user_signal("unit_details_changed")
	add_user_signal("action_details_changed")
	
# Ready Functions
# --------------------
func _ready():
	# Basic values
	_action_points_left = Unit_Properties.get_action_points_max(_type)
	_can_attack = true
	_hit_points_left = Unit_Properties.get_hit_points_max(_type)
	
	# Set up cooldowns
	var actions : Array = Unit_Properties.get_actions(self._type)
	for action : Action in actions:
		_action_states[action.get_display_name()] = {
			"last_use_turn": -action.get_cooldown(),
			"uses_left": action.get_usage_limit()
		}
	
	# Set up the label
	if _unit_label:
		_unit_label._unit_label_content.set_and_update(self, _unit_label)
		_unit_label.force_update_viewport_size()
	else:
		printerr("Unit.gd -> _ready(): No unit label assigned!")

# Private Methods
# --------------------
func destroy_unit(game_manager : Game_Manager):
	# Get the reference to the tile
	var tile : Tile = game_manager.get_tile_matrix()[_matrix_tile_position.x][_matrix_tile_position.z]
	
	# Remove the unit from tile
	tile.remove_unit_from_tile(self)
	
	# Clear player's selections if the unit is selected
	var selection = game_manager.get_mouse_selection()
	if typeof(selection) == TYPE_OBJECT && selection == self:
		MouseModeManager.remove_selection()
	
	# Remove unit from player manager
	PlayerManager.remove_unit(self)
	
	# Delete the unit
	queue_free()

# Public Methods
# --------------------

# Returns 'true' if action_points are left
func offset_action_points(offset : int) -> bool:
	# Update value
	_action_points_left += offset
	if _action_points_left < 0: _action_points_left = 0
	
	# Update UI
	if _unit_label: 
		_unit_label.update_all(self)
		
	emit_signal("unit_details_changed")
	
	return _action_points_left > 0

# Returns 'true' if hp is above 0, 'false' if below or equal 0
func offset_hit_points(ap_damage : float, he_damage : float, tile : Tile) -> bool:
	# Calculate multipliers
	var unit_ap_mutli = Unit_Properties.get_ap_mod(self.get_type())
	var unit_he_mutli = Unit_Properties.get_he_mod(self.get_type())
	var tile_base_multi = Tile_Properties.get_defense_modifier(tile.get_type())
	var tile_ap_multi = tile.get_ap_stacking_mod()
	var tile_he_multi = tile.get_he_stacking_mod()
	
	# Update HP
	_hit_points_left -= ap_damage * tile_base_multi * tile_ap_multi * unit_ap_mutli
	_hit_points_left -= he_damage * tile_base_multi * tile_he_multi * unit_he_mutli
	
	# Update UI
	if _unit_label: 
		_unit_label.update_all(self)
	
	emit_signal("unit_details_changed")
	
	return _hit_points_left > 0
	
# Sets action points to the value in Unit_Properties
func reset_action_points():
	# Update value
	_action_points_left = Unit_Properties.get_action_points_max(_type)
	_can_attack = true
	
	# Update UI
	if _unit_label: 
		_unit_label.update_all(self)
		
	emit_signal("unit_details_changed")

func update_action_as_used(action_display_name : String, present_turn : int):
	var state = _action_states[action_display_name]
	if state:
		state["last_use_turn"] = present_turn
		state["uses_left"] -= 1
	else:
		printerr("Unit.gd -> update_action_as_used: an action was added during runtime and won't be handled properly until restart!")
	
	emit_signal("action_details_changed")

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

func get_label() -> Unit_Label_3D:
	return _unit_label

func get_can_attack() -> bool:
	return _can_attack

func get_action_last_use_turn(action_display_name : String) -> int: 
	var state = _action_states[action_display_name]
	if state:
		return state["last_use_turn"]
	else:
		printerr("Unit.gd -> get_action_last_use_turn: an action was added during runtime and won't be handled properly until restart!")
		return -404
		
func get_action_uses_left(action_display_name : String) -> int:
	var state = _action_states[action_display_name]
	if state:
		return state["uses_left"]
	else:
		printerr("Unit.gd -> get_action_last_use_turn: an action was added during runtime and won't be handled properly until restart!")
		return 404

# Setters
# --------------------
func set_player_owner(id : int): 
	_player_owner_id = id
	emit_signal("unit_details_changed")
	
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

func set_can_attack(value : bool):
	_can_attack = value
