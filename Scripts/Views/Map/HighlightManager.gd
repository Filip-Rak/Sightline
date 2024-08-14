extends Node

class_name Highlight_Manager

# Attributes
# --------------------

# Highlighting materials
var _turn_enabled_mass_mat : Material = preload("res://Assets/Resources/Mat_move.tres")
var _turn_enabled_mouse_mat : Material = preload("res://Assets/Resources/Mat_attack.tres")
var _turn_disabled_mat : Material = preload("res://Assets/Resources/Mat_disabled.tres")

# Mass highlight
var _mass_highlight_material : Material = _turn_disabled_mat
var _mass_highlight_group_name : String = "mass_highlighted_tiles"

# Mouse
var _mouse_over_highlight : Node3D
var _mouse_over_highlight_material : Material = _turn_disabled_mat
var _mouse_over_highlight_previous_material : Material

# Other scripts
var _game_manager : Game_Manager

# Constructor
# --------------------
func _init(gm : Game_Manager):
	_game_manager = gm

# Private Functions
# --------------------
func _redo_highlighting(mass_material : Material, mouse_material : Material):
	# Set new materials
	_mass_highlight_material = mass_material
	_mouse_over_highlight_previous_material = mass_material
	_mouse_over_highlight_material = mouse_material
	
	# Recalculate the selection
	match MouseModeManager.current_mouse_mode:
		MouseModeManager.MOUSE_MODE.SPAWN: _game_manager.select_spawnable_tiles()
		MouseModeManager.MOUSE_MODE.MOVE: _game_manager.select_moveable_tiles()

# Public Functions
# --------------------
func mass_highlight_tiles(tiles : Array):
	for tile in tiles:
		# Get the MeshInstance3D child
		for child in tile.get_children():
			if child is MeshInstance3D:
				# Apply the highlight material
				child.material_overlay = _mass_highlight_material
				
				# Save highlited tiles to their group
				tile.add_to_group(_mass_highlight_group_name)
				break
				
func clear_mass_highlight():
	# Get all nodes in the group
	var highlighted = get_tree().get_nodes_in_group(_mass_highlight_group_name)
	
	# Clear the highlighting material
	for tile in highlighted:
		
		# Get the MeshInstance3D child
		for child in tile.get_children():
			if child is MeshInstance3D:
				
				# Clear highlight material
				child.material_overlay = null
				break
				
		# Remove the tile from the group
		tile.remove_from_group(_mass_highlight_group_name)

func clear_mouse_over_highlight():
	if _mouse_over_highlight:
		for child in _mouse_over_highlight.get_children():
				if child is MeshInstance3D:
					child.material_overlay = _mouse_over_highlight_previous_material
					_mouse_over_highlight = null
					break

func mouse_over_highlghted_tile(tile : Node3D):
	# Clear previous mouse highlight
	clear_mouse_over_highlight()
	
	# Check if mouse points into a tile it can select
	if tile.is_in_group(_mass_highlight_group_name):
		for child in tile.get_children():
			if child is MeshInstance3D:
				# Save previous material
				_mouse_over_highlight_previous_material = child.material_overlay
				
				# Highlight with new material
				child.material_overlay = _mouse_over_highlight_material
				_mouse_over_highlight = tile
				break

func redo_highlighting(player_turn : bool):
	if player_turn:
		_redo_highlighting(_turn_enabled_mass_mat, _turn_enabled_mouse_mat)
	else:
		_redo_highlighting(_turn_disabled_mat, _turn_disabled_mat)

# Getters
# --------------------
func get_mass_highlight_group_name() -> String:
	return _mass_highlight_group_name
