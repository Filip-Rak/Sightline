extends Node

# Attributes
# --------------------

# Exported settings
@export var map_root : Node3D

# Map related variables
var tile_matrix = []
var x_size : int
var z_size : int

# Functions
# --------------------

# Function for receiving game settings
func initialize(_parameters):
	# Set up selected settings here
	
	# Extract dimensions of the map and save to global vars
	get_map_dimensions()
	
	# Build the matrix with now known sizes
	initialize_tile_matrix()
	
	# Fill the matrix with GridTiles
	load_tiles_to_matrix()
	
	# Modify the matrix based on the settings
	
func get_map_dimensions():
		# Get all the children
	var children = map_root.get_children()
	
	# Make sure the map isn't empty
	if children.size() == 0: 
		printerr("The map is either empty or set up incorrectly!") 
		return
	
	# Find max x and z coordinate in maps's childredn (GridTiles)
	var max_x : int = children[0].position .x
	var max_z : int = children[0].position .z
	
	for child in children:
		if child.position .x > max_x: max_x = child.position .x
		if child.position .z > max_z: max_z = child.position .z
		
	x_size = max_x + 1
	z_size = max_z + 1
	# print ("MAX X: %s\tMAX Z: %s" % [max_x, max_z])
	
func initialize_tile_matrix():
	for i in x_size:
		tile_matrix.append([])
		for j in z_size:
			tile_matrix[i].append(GridTile.new())
			
func load_tiles_to_matrix():
	var tiles = map_root.get_children()
	
	for tile in tiles:
		tile_matrix[tile.position.x][tile.position.y] = tile
	
	
