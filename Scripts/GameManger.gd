extends Node

# Attributes
# --------------------

var map_instance
var tile_matrix = []

# Functions
# --------------------

# Function for receiving game settings
func initialize(parameters):
	# Set selected map as something here
	var selected_map = preload("res://Scenes/MapTest.tscn")
	# Along with otehr settings
	
	# Instantiate the map
	map_instance = selected_map.instance()
	add_child(map_instance)
	
	# Init the tile matrix
	initialize_tile_matrix()
	
	# Modify the matrix based on the setting
	
func initialize_tile_matrix():
	# Find max x and z coordinate in maps's childredn (GridTiles)
	print(map_instance.get_children())
	
