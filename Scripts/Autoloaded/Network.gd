extends Node

# Attributes
# --------------------

# Player data
var players = {}

# Reference to the map stored for greater accesibility over the network
var tile_matrix : Array

# Remote Procedure Calls
# --------------------

@rpc("any_peer", "call_local")
func spawn_unit(target_tile_path : NodePath, unit_to_spawn : PlayerUnit.unit_type, spawning_player : int, unit_group_name : String, parent_node_path : NodePath):
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


# Setters
# --------------------
func set_tile_matrix(tiles):
	tile_matrix = tiles
