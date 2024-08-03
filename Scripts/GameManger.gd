extends Node

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

# Highlightin a group of tiles
var mass_highlight_group_name : String = "highlighted_tiles"
var mass_highlight_material : Material = preload("res://Assets/Resources/Mat_move.tres")

# Highlighting the tile under the mouse
var mouse_highlight : Node3D
# Mouse highlight probably shouldnt use its own materials, but rather amplify the group one's
# Unless the tile isn't highlited in the first place - only then should it put material on it's own

# Player
var player_team_id = 1
@onready var camera = $PlayerCamera

# Ready Functions
# --------------------

func _ready():
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
	if Input.is_action_just_pressed("function_debug"): highlight_spawnable_tiles(PlayerUnit.unit_type.IMV)
	# get_hooverd_on_selectable()

# External Interaction Functions
# --------------------

# Function for receiving game settings
func set_up(_parameters):
	# Set up selected settings here
	# Modify the matrix based on the settings
	pass

func highlight_spawnable_tiles(unit : PlayerUnit.unit_type):
	# Discard all the previous highlits
	un_highlight_tiles()
	
	# Find all the tiles suitable for spawning
	var good_tiles = []
	for i in x_size:
		for j in z_size:
				if tile_matrix[i][j].get_is_a_spawn():
					if tile_matrix[i][j].get_team_id() == player_team_id:
						if tile_matrix[i][j].get_accesible_to().find(unit) != -1:
							good_tiles.append(tile_matrix[i][j])
	
	# Highlight these tiles
	highlight_tiles(good_tiles)

func highlight_tiles(tiles : Array):
	for tile in tiles:
		# Get the MeshInstance3D child
		for child in tile.get_children():
			if child is MeshInstance3D:
				# Apply the highlight material
				child.material_overlay = mass_highlight_material
				
				# Save highlited tiles to their group
				tile.add_to_group(mass_highlight_group_name)
				break

func un_highlight_tiles():
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
		
		
# Utility Functions
# --------------------

# Return 'false' when no hit, or when the hit is not a selectable
func get_hooverd_on_selectable():
	var hit = camera.screen_point_to_ray()
	
	if hit:
		var parent = hit["collider"].get_parent()
		if parent:
			var grand_parent = parent.get_parent()
			if grand_parent:
				return grand_parent
		
	return false
		
