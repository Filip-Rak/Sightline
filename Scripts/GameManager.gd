extends Node3D

# Atributes
# --------------------

# GridMap
@onready var grid_map = $Environment/GridMap
var tile_matrix = []
var grid_length_x : int = 6
var grid_length_z : int = 8

# Ready Functions
# --------------------
func _ready():
	intialize_tile_matrix()
	load_gridmap_to_matrix()
	
# Creates a matrix of placeholder GridTiles
func intialize_tile_matrix():
	for i in grid_length_x:
		tile_matrix.append([])
		tile_matrix[i].resize(grid_length_z)
		for j in grid_length_z:
			# Set every tile as a placeholder
			tile_matrix[i][j] = GridTile.new()

func load_gridmap_to_matrix():
	var used_cells = grid_map.get_used_cells()
	for cell_position in used_cells:
		var i = cell_position.x + int(grid_length_x / 2.0)
		var j = int(cell_position.z + grid_length_z / 2.0)
		
		tile_matrix[i][j].type = grid_map.get_cell_item(cell_position)
		print("X: %s\tZ: %s\tTYPE: %s" % [cell_position.x, cell_position.z, grid_map.mesh_library.get_item_name(tile_matrix[i][j].type)])

# Process Functions
# --------------------
func _process(delta):
	pass
