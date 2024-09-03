extends Node

# Attributes
# --------------------

# Template. Index is team_id
#	player_ids : Array [int]
#	zones : Array [Tile]
# 	score : float

var _teams : Dictionary = {}

# Public Methods
# --------------------
func set_up_teams():
	for player_id : int in PlayerManager.get_players().keys():
		# Get assigned team id
		var team_id : int = PlayerManager.get_team_id(player_id)
		
		# If team doesnt exist
		if !_teams.has(team_id):
			# Create the team
			_create_team(team_id)
		
		# Add player to the team
		_teams[team_id]["player_ids"].append(player_id)
		
	# Call all clients to synchronise their data
	rpc("_sync_to_host", _teams)

# Private Methods
# --------------------
func _create_team(team_id : int):
	_teams[team_id] = {
		"player_ids" : [],
		"zones" : [],
		"score" : 0.0
	}
	
# Remote Procedure Calls
# --------------------
@rpc("authority")
func _sync_to_host(teams : Dictionary):
	_teams = teams
	
	print ("----------- CLIENT ID : %s -----------" % multiplayer.get_unique_id())
	print (_teams)
	
	
	
