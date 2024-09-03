extends Node

# Attributes
# --------------------

# Template. Index is team_id
#	player_ids : Array [int]
#	tile_matrix_x : Array [int]
#	tile_matrix_z : Array [int]
# 	score : float

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

# Private Methods
# --------------------
func _create_team(team_id : int):
	_teams[team_id] = {
		"player_ids" : [],
		"tile_matrix_x" : [],
		"tile_matrix_z" : [],
		"score" : 0.0
	}
	
func _fill_owned_tiles(team_id : int, tile_matrix : Array) -> Array:
	var tiles : Array = []
	for x in range(tile_matrix.size()):
		for z in range(tile_matrix[x].size()):
			if tile_matrix[x][z].get_team_id() == team_id:
				_teams[team_id]["tile_matrix_x"] = x
				_teams[team_id]["tile_matrix_z"] = z
				
	return tiles
	
	
# Remote Procedure Calls
# --------------------
@rpc("authority")
func _sync_to_host(teams : Dictionary):
	_teams = teams
	
	print("-------- CLIENT ID %s --------------" % multiplayer.get_unique_id())
	for team_id in _teams.keys():
		print ("TEAM_ID %s" % team_id)
		print (_teams[team_id]["tile_matrix_x"])
		print (_teams[team_id]["tile_matrix_z"])
