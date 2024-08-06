extends Node


func get_reachable_tiles(tile_matrix : Array, unit : PlayerUnit) -> Dictionary:
	var directions = [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]
	var reachable_tiles = []
	var queue = []
	var visited = {}
	var movement_costs = {}
	
	var start_pos = unit.get_matrix_tile_position()
	var action_points = unit.get_action_points_left()
	
	# Start from the initial position with total movement points
	queue.append({"pos": start_pos, "ac_left": action_points})
	visited[start_pos] = true
	movement_costs[start_pos] = 0
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var current_pos = current["pos"]
		var ac_left = current["ac_left"]
		
		# Get the current tile
		var current_tile = tile_matrix[current_pos.x][current_pos.z]
		
		# Add the current position to reachable tiles
		reachable_tiles.append(current_tile)
		
		# Explore neighbors
		for direction in directions:
			var neighbor_pos = current_pos + direction
			
			# Check if neighbor is within bounds
			if neighbor_pos.x < 0 || neighbor_pos.x >= tile_matrix.size(): continue
			if neighbor_pos.z < 0 || neighbor_pos.z >= tile_matrix[0].size(): continue
			
			var neighbor_tile = tile_matrix[neighbor_pos.x][neighbor_pos.z]
			var movement_cost = neighbor_tile.get_movement_cost()
			
			# Check if the unit has enough movement points to move to this tile
			if ac_left < movement_cost: continue
			
			# Check if tile hasn't been visited yt
			if visited.has(neighbor_pos): continue
			
			# Check if neighbor is passable
			if neighbor_tile.get_accesible_to().find(unit.type) == -1 : continue
			
			# Check if the tile has no enemy units
			var in_tile : bool = false
			for unit_in_tile in neighbor_tile.get_units_in_tile():
				# In future change to team ID
				if unit_in_tile.get_player_owner_id() != unit.get_player_owner_id():
					in_tile = true
					break
			
			if in_tile: continue
			
			# Update the tile
			queue.append({"pos": neighbor_pos, "ac_left":ac_left - movement_cost})
			visited[neighbor_pos] = true
			movement_costs[neighbor_pos] = movement_costs.get(current_pos, 0) + movement_cost

	return {"tiles": reachable_tiles, "costs": movement_costs}

