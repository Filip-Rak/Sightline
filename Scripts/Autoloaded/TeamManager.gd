extends Node

# Attributes
# --------------------

# Template. Index is team_id
#	player_ids : Array [int]
#	tile_matrix_pos : [Vector3],
#	score : float

var _teams : Dictionary = {}

# Public Methods
# --------------------
func set_up_teams(tile_matrix : Array):
	for player_id : int in PlayerManager.get_players().keys():
		# Get assigned team id
		var team_id : int = PlayerManager.get_team_id(player_id)
		
		# If team doesnt exist
		if !_teams.has(team_id):
			# Create the team
			_create_team(team_id)
		
		# Add player to the team
		_teams[team_id]["player_ids"].append(player_id)
		
		# Update tiles for specific team
		_fill_owned_tiles(team_id, tile_matrix)
		
	# Call all clients to synchronise their data
	rpc("_sync_to_host", _teams)

func change_tile_owner(matrix_pos : Vector3, old_owner_id : int, new_owner_id : int):
	if _teams.has(old_owner_id): _teams[old_owner_id]["tile_matrix_pos"].erase(matrix_pos)
	if _teams.has(new_owner_id): _teams[new_owner_id]["tile_matrix_pos"].append(matrix_pos)
	
	print ("CLIENT %s" % multiplayer.get_unique_id())
	print (_teams)

func update_score(tile_matrix : Array):
	for team_id : int in _teams.keys():
		var addition = 0
		for pos : Vector3 in _teams[team_id]["tile_matrix_pos"]:
			addition += tile_matrix[pos.x][pos.z].get_point_value()
			
# Private Methods
# --------------------
func _create_team(team_id : int):
	_teams[team_id] = {
		"player_ids" : [],
		"tile_matrix_pos" : [],
		"score" : 0.0
	}
	
func _fill_owned_tiles(team_id : int, tile_matrix : Array):
	for x in range(tile_matrix.size()):
		for z in range(tile_matrix[x].size()):
			if tile_matrix[x][z].get_team_id() == team_id:
				_teams[team_id]["tile_matrix_pos"].append(tile_matrix[x][z].get_matrix_position())
	
# Remote Procedure Calls
# --------------------
@rpc("authority")
func _sync_to_host(teams : Dictionary):
	_teams = teams
