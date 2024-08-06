extends Node

# Globals
const directions = [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]
var f_costs = {}
var g_costs = {}

# Function to get reachable tiles based on unit's movement points
func get_reachable_tiles(tile_matrix : Array, unit : PlayerUnit) -> Dictionary:
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
	
	# BFS to find all reachable tiles
	while queue.size() > 0:
		var current = queue.pop_front()
		var current_pos = current["pos"]
		var ac_left = current["ac_left"]
		
		# Get the current tile
		var current_tile = tile_matrix[current_pos.x][current_pos.z]
		
		# Add the current tile to reachable tiles
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
			# This check should be rewritten to happen ONLY for visible enemies, which is currently not implemented anyway
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

	# Return reachable tiles and their movement costs
	return {"tiles": reachable_tiles, "costs": movement_costs}

# Function to find the path from start_pos to end_pos
func find_path(tile_matrix : Array, unit : PlayerUnit, end_pos : Vector3, viable_tiles : Array) -> Array:
	# Make sure f_costs and g_costs are reset from prior pathing
	f_costs.clear()
	g_costs.clear()
	
	var open_list = []
	var closed_list = {}
	var came_from = {}
	
	var start_pos : Vector3 = unit.get_matrix_tile_position()

	open_list.append(start_pos)
	g_costs[start_pos] = 0
	f_costs[start_pos] = heuristic_cost_estimate(start_pos, end_pos)
	
	# A* algorithm to find the path
	while open_list.size() > 0:
		# Sort the open list by f_cost
		open_list.sort_custom(compare_f_costs)
		
		var current_pos = open_list.pop_front()
		if current_pos == end_pos: 
			return reconstruct_path(came_from, current_pos)
		
		closed_list[current_pos] = true
		
		# Explore neighbors
		for direction in directions:
			var neighbor_pos = current_pos + direction
			
			# Make sure neighbours are within bounds
			if neighbor_pos.x < 0 || neighbor_pos.x >= tile_matrix.size(): continue
			if neighbor_pos.z < 0 || neighbor_pos.z >= tile_matrix[0].size(): continue
			
			var neighbor_tile = tile_matrix[neighbor_pos.x][neighbor_pos.z]
			
			# If the tile is on closed list diregard it
			if closed_list.has(neighbor_pos): continue
			
			# Discard tiles which were not shown to the player as valid
			if !viable_tiles.has(neighbor_tile): continue
			
			# Very likely redundant. viable_tiles should already be past this check
			# if neighbor_tile.get_accesible_to().find(unit.type) == -1 : continue
			
			# Calculate the g_cost from movement
			var tentative_g_cost = g_costs[current_pos] + neighbor_tile.get_movement_cost()
			
			# Skip the tile if the cost has been exceeded
			if tentative_g_cost > unit.get_action_points_left(): continue
			
			# Check if the Path is Better
			if !g_costs.has(neighbor_pos) || tentative_g_cost < g_costs[neighbor_pos]:
				came_from[neighbor_pos] = current_pos
				g_costs[neighbor_pos] = tentative_g_cost
				f_costs[neighbor_pos] = g_costs[neighbor_pos] + heuristic_cost_estimate(neighbor_pos, end_pos)
				
				# Update the list
				if neighbor_pos not in open_list: 
					open_list.append(neighbor_pos)

	return []

func compare_f_costs(a, b) -> int:
	if f_costs[a] < f_costs[b]:
		return -1
	elif f_costs[a] > f_costs[b]:
		return 1
	else:
		return 0

func reconstruct_path(came_from : Dictionary, current_pos : Vector3) -> Array:
	var total_path = [current_pos]
	while came_from.has(current_pos):
		current_pos = came_from[current_pos]
		total_path.append(current_pos)
	total_path.reverse()
	return total_path

func heuristic_cost_estimate(start_pos : Vector3, end_pos : Vector3) -> float:
	return abs(start_pos.x - end_pos.x) + abs(start_pos.z - end_pos.z)

func get_path_cost(tile_matrix : Array, path : Array) -> int:
	var cost : int = 0
	for tile_pos in path:
		cost += tile_matrix[tile_pos.x][tile_pos.z].get_movement_cost()
		
	return cost
