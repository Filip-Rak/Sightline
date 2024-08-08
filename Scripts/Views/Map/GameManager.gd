extends Node

class_name Game_Manager

# Attributes
# --------------------

# Exported settings
@export var map_root : Node3D

# Map variables
var tile_matrix = []
const tile_group_name : String = "tiles"
var positional_offset_x : int
var positional_offset_z : int
var x_size : int
var z_size : int

# Units
const unit_group_name : String = "units"

# Highlighting a group of units or tiles by the game
var mass_highlight_group_name : String = "mass_highlighted_tiles"
var mass_highlight_material : Material = preload("res://Assets/Resources/Mat_move.tres")

# Highlighting a unit or tile by the mouse
var mouse_over_highlight : Node3D
# Mouse highlight probably shouldnt use its own materials, but rather amplify the group one's
# Unless the tile isn't highlited in the first place - only then should it put a material on it's own

# This is more of a stop gap solution
var mouse_over_highlight_material : Material = preload("res://Assets/Resources/Mat_attack.tres")
var mouse_over_highlight_previous_material : Material

# This will store selected unit or a tile. It will also be highlighted
# Difference is, this one is selected and should be higlighted as 'active'
# mouse_over_highlight is for hovered over stuff
# Both can only be one thing at the time
var mouse_selection

# Path finding
var reachable_tiles_and_costs : Dictionary

# Player
var player_team_id = 1
@onready var camera = $PlayerCamera

# Ready Functions
# --------------------

func _ready():
	# Set up the mouse mode manager
	MouseModeManager.set_game_manager(self)
	MouseModeManager.set_camera(camera)
	MouseModeManager.set_mouse_mode(MouseModeManager.MOUSE_MODE.INSPECTION)
	
	# Load the map and get its properties
	# In the future this is where procedural generation would be added
	var map_loader = Map_Loader.new()
	map_loader.load_map(map_root, tile_group_name)
	
	tile_matrix = map_loader.get_tile_matrix()
	x_size = map_loader.get_x_size()
	z_size = map_loader.get_z_size()
	positional_offset_x = map_loader.get_pos_offset_x()
	positional_offset_z = map_loader.get_pos_offset_z()

# External Interaction Functions
# --------------------

# Function for receiving game settings
func set_up(_parameters):
	# Set up selected settings here
	# Modify the matrix based on the settings
	pass

func highlight_spawnable_tiles(unit : PlayerUnit.unit_type):
	# Discard all the previous highlits
	# Order here is very important!
	clear_mouse_over_highlight() 
	clear_mass_highlight()
	
	# Find all the tiles suitable for spawning
	var good_tiles = []
	for i in x_size:
		for j in z_size:
				if tile_matrix[i][j].get_is_a_spawn():
					if tile_matrix[i][j].get_team_id() == player_team_id:
						if tile_matrix[i][j].get_accesible_to().find(unit) != -1:
							good_tiles.append(tile_matrix[i][j])
	
	# Highlight these tiles
	mass_highlight_tiles(good_tiles)

func mass_highlight_tiles(tiles : Array):
	for tile in tiles:
		# Get the MeshInstance3D child
		for child in tile.get_children():
			if child is MeshInstance3D:
				# Apply the highlight material
				child.material_overlay = mass_highlight_material
				
				# Save highlited tiles to their group
				tile.add_to_group(mass_highlight_group_name)
				break

func clear_mass_highlight():
	# Get all nodes in the group
	var highlighted = get_tree().get_nodes_in_group(mass_highlight_group_name)
	
	# Clear the highlighting material
	for tile in highlighted:
		
		# Get the MeshInstance3D child
		for child in tile.get_children():
			if child is MeshInstance3D:
				
				# Clear highlight material
				child.material_overlay = null
				break
				
		# Remove the tile from the group
		tile.remove_from_group(mass_highlight_group_name)

func mouse_over_highlight_tile(tile : Node3D):
	# Clear previous mouse highlight
	clear_mouse_over_highlight()
	
	# Check if mouse points into a tile it can select
	if tile.is_in_group(mass_highlight_group_name):
		for child in tile.get_children():
			if child is MeshInstance3D:
				# Save previous material
				mouse_over_highlight_previous_material = child.material_overlay
				
				# Highlight with new material
				child.material_overlay = mouse_over_highlight_material
				mouse_over_highlight = tile
				break

func clear_mouse_over_highlight():
	if mouse_over_highlight:
		for child in mouse_over_highlight.get_children():
				if child is MeshInstance3D:
					child.material_overlay = mouse_over_highlight_previous_material
					mouse_over_highlight = null
					break
	
func try_spawning_a_unit(target_tile : Node3D):
	# Make sure the selected tile is available for spawning
	if !target_tile.is_in_group(mass_highlight_group_name): return
	
	# Make sure a unit is selected
	if mouse_selection == null: return
	
	# Spawn the unit itself for all players
	var spawn_path : NodePath = target_tile.get_path()
	var tree : NodePath = self.get_path()
	var player_id : int = multiplayer.get_unique_id()
	
	rpc("spawn_unit", spawn_path, mouse_selection, player_id, tree) 
	
	# Clear all selections after spawning - consider not doing so for 'shift' effect
	clear_mouse_over_highlight()
	clear_mass_highlight()
	mouse_selection = null
		
	# Change mouse mode to inspect
	MouseModeManager.set_mouse_mode(MouseModeManager.MOUSE_MODE.INSPECTION)
	
func try_moving_a_unit(target_tile : GridTile):
	# Make sure the selected tile is reachable and mouse selection is a unit
	if !mouse_selection.is_in_group(unit_group_name): return
	if reachable_tiles_and_costs["tiles"].find(target_tile) == -1: return
	
	# Prepare argument for path finding call
	var unit = mouse_selection
	var target_pos = target_tile. get_matrix_position()
	var available_tiles = reachable_tiles_and_costs["tiles"]
	
	var path : Array = PathFinding.find_path(tile_matrix, unit, target_pos, available_tiles)
	
	if path.size() > 0:
		path.remove_at(0)
	
	# Trim the path just before the danger
	# This shouldn't work every time!
	# path = trim_path_before_danger(tile_matrix, path)
	
	# Move the unit on the server
	rpc("move_unit", unit.get_path(), path)
	
	# Refresh the highlighting
	if unit.get_action_points_left() > 0:
		highlight_moveable_tiles()
	else:
		clear_mouse_over_highlight()
		clear_mass_highlight()
	
func highlight_moveable_tiles():
	# Get all the tiles where the unit can move
	reachable_tiles_and_costs = PathFinding.get_reachable_tiles(tile_matrix, mouse_selection)
	
	# Clear previous highlighting
	clear_mass_highlight()
	
	# Highlight new tiles
	mass_highlight_tiles(reachable_tiles_and_costs["tiles"])
	
	# Change mouse mode to move
	MouseModeManager.set_mouse_mode(MouseModeManager.MOUSE_MODE.MOVE)

# Remote Procedure Calls
# --------------------
@rpc("any_peer", "call_local")
func spawn_unit(target_tile_path : NodePath, unit_to_spawn : PlayerUnit.unit_type, spawning_player: int, parent_node_path : NodePath):
	# Get the tile to spawn in
	var target_tile = get_node(target_tile_path)
	
	# Instantiate the unit and set it's properties
	var spawned_unit = PlayerUnit.get_scene_of_type(unit_to_spawn).instantiate()
	spawned_unit.position = target_tile.position
	spawned_unit.set_player_owner(spawning_player)
	spawned_unit.set_matrix_tile_position(target_tile.get_matrix_position())
	spawned_unit.add_to_group(unit_group_name)
	
	# Update the tile properties
	target_tile.units_in_tile.append(spawned_unit)
	
	# Add the unit to the tree
	var tree = get_node(parent_node_path)
	tree.add_child(spawned_unit)

@rpc("any_peer", "call_local")
func move_unit(path_to_unit : NodePath, route : Array):
	if path_to_unit == null: return
	if route == null: return
	
	# Get the unit
	var unit = get_node(path_to_unit)
	if unit == null: return
	
	# Here would be required logic for playing animations and moving the unit
	# At the moment just snap the unit at it's final destination
	
	var final_dest = route.pop_back()
	route.append(final_dest)
	
	if final_dest == null: return
	
	# Delete the unit from previous tile
	var previous_pos : Vector3 = unit.get_matrix_tile_position()
	tile_matrix[previous_pos.x][previous_pos.z].remove_unit_from_tile(unit)

	# Move the unit
	unit.position = tile_matrix[final_dest.x][final_dest.z].position
	tile_matrix[final_dest.x][final_dest.z].add_unit_to_tile(unit)
	unit.set_matrix_tile_position(final_dest)
	
	# Offset action points
	var route_cost = PathFinding.get_path_cost(tile_matrix, route)
	unit.offset_action_points(-route_cost)

# Link Functions
# --------------------
func select_unit_for_spawn(type : PlayerUnit.unit_type):
	mouse_selection = type
	highlight_spawnable_tiles(type)
	MouseModeManager.set_mouse_mode(MouseModeManager.MOUSE_MODE.SPAWN)
	
# Setters
# --------------------
func set_mouse_selection(selection):
	mouse_selection = selection

# Getters
# --------------------
func get_tile_group_name() -> String:
	return tile_group_name

func get_unit_group_name() -> String:
	return unit_group_name
