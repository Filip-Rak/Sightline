extends Node

# Utility Functions
# --------------------
func find_neighbours_pos(tile_matrix : Array, pos : Vector3) -> Array:
	const directions = [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]
	
	var neighbors = []
	
	for direction in directions:
		var neighbor_pos = pos + direction
		if is_in_matrix(tile_matrix.size(), tile_matrix[0].size(), neighbor_pos):
			neighbors.append(neighbor_pos)
	
	return neighbors
		
func is_in_matrix(x_size : int, z_size : int, pos : Vector3) -> bool:
	if pos.x < 0 || pos.x >= x_size: return false
	if pos.z < 0 || pos.z >= z_size: return false
	
	return true
