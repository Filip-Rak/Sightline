extends Node

class_name Game_Manager

# Attributes
# --------------------

# Exported settings
@export var map_root : Node3D

# Map related variables
var tile_matrix = []
var positional_offset_x : int
var positional_offset_z : int
var x_size : int
var z_size : int

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
	
	# Extract dimensions of the map and save to global vars
	get_map_dimensions()
	
	# Build the matrix with now known sizes
	initialize_tile_matrix()
	
	# Fill the matrix with GridTiles
	load_tiles_to_matrix()

func get_map_dimensions():
	# Get all the children
	var children = map_root.get_children()
	
	# Make sure the map isn't empty
	if children.size() == 0: 
		printerr("The map is either empty or set up incorrectly!") 
		return
	
	# Find max and min x and z coordinate in maps's childredn (GridTiles)
	var max_x : int = children[0].position .x
	var min_x : int = children[0].position .x
	var max_z : int = children[0].position .z
	var min_z : int = children[0].position .z
	
	for child in children:
		if child.position.x > max_x: max_x = child.position.x
		if child.position.x < min_x: min_x = child.position.x
		if child.position.z > max_z: max_z = child.position.z
		if child.position.z < min_z: min_z = child.position.z
		
	positional_offset_x = min_x
	positional_offset_z = min_z
		
	x_size = max_x - min_x + 1
	z_size = max_z - min_z + 1
	# print ("SIZE X: %s\tSIZE Z: %s" % [x_size, z_size])
	# print ("OFFSET X: %s\tOFFSET Z: %s" % [positional_offset_x, positional_offset_z])
	
func initialize_tile_matrix():
	for i in x_size:
		tile_matrix.append([])
		for j in z_size:
			tile_matrix[i].append(GridTile.new())
			
func load_tiles_to_matrix():
	var tiles = map_root.get_children()
	
	for tile in tiles:
		var x : int = int(tile.position.x) - positional_offset_x
		var z : int = int(tile.position.z) - positional_offset_z
		tile_matrix[x][z] = tile
		# print ("[%s][%s] = %s" % [x, z, tile.type])
	
# Process Functions
# --------------------
func _process(_delta : float):
	if Input.is_action_just_pressed("function_debug"): 
		# mouse_selection = PlayerUnit.new() # No no, spawn the scene. Var should hold the scene
		highlight_spawnable_tiles(PlayerUnit.unit_type.INFANTRY)
		MouseModeManager.current_mouse_mode = MouseModeManager.MOUSE_MODE.SPAWN

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
	
func spawn_selected_unit(target_tile : Node3D):
	# Make sure the selected tile is available for spawning
	if !target_tile.is_in_group(mass_highlight_group_name): return
	
	# Make sure a unit is selected
	# if !mouse_selection: return # Disabled for testing
	
	# Spawn the unit
	print("Spawning a unit at: \n\tPosition: x = %s\t z = %s\n\tType of tile: %s\n\tName: %s\n\tType of unit: %s" % [target_tile.position.x, target_tile.position.z, target_tile.type, target_tile.name, mouse_selection])
		
	# Clear all selections after spawning - consider not doing so for 'shift' effect
	clear_mouse_over_highlight()
	clear_mass_highlight()
	mouse_selection = null
		
	# Change mouse mode to inspect
	MouseModeManager.current_mouse_mode = MouseModeManager.MOUSE_MODE.INSPECTION
	
# Link Functions
# --------------------

func select_unit_for_spawn(type : PlayerUnit.unit_type):
	mouse_selection = PlayerUnit.get_scene_of_type(type) # No no, spawn the scene. Var should hold the scene
	highlight_spawnable_tiles(type)
	MouseModeManager.current_mouse_mode = MouseModeManager.MOUSE_MODE.SPAWN
