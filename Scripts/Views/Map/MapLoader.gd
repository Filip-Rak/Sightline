extends Node

class_name Map_Loader

# Attributes
# --------------------

# Assigned externally
var root : Node3D
var group_name_for_tiles : String

# Results of map loading
var tile_matrix = []
var positional_offset_x : int
var positional_offset_z : int
var x_size : int
var z_size : int

# Map Loading Functions
# --------------------
func load_map(map_root : Node3D, tile_group_name):
	root = map_root
	group_name_for_tiles = tile_group_name
	
	# Extract dimensions of the map and save to global vars
	_get_map_dimensions()
	
	# Build the matrix with now known sizes
	_initialize_tile_matrix()
	
	# Fill the matrix with GridTiles
	_load_tiles_to_matrix()

func _get_map_dimensions():
	# Get all the children
	var children = root.get_children()
	
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
	
func _initialize_tile_matrix():
	for i in x_size:
		tile_matrix.append([])
		for j in z_size:
			tile_matrix[i].append(GridTile.new())
			
func _load_tiles_to_matrix():
	
	var tiles = root.get_children()
	
	for tile in tiles:
		var x : int = int(tile.position.x) - positional_offset_x
		var z : int = int(tile.position.z) - positional_offset_z
		tile_matrix[x][z] = tile
		tile.set_matrix_position(Vector3(x, 0, z))
		tile.add_to_group(group_name_for_tiles)
		# print ("[%s][%s] = %s" % [x, z, tile.type])
	

# Getters
# --------------------
func get_tile_matrix() -> Array:
	return tile_matrix

func get_x_size() -> int:
	return x_size

func get_z_size() -> int:
	return x_size

func get_pos_offset_x() -> int:
	return positional_offset_x

func get_pos_offset_z() -> int:
	return positional_offset_z
