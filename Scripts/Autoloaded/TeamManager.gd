extends Node

# Attributes
# --------------------

# Template. Index is team_id
#	player_ids : Array [int]
#	zones : Array [Tile]

var _teams : Dictionary = {}

# Public Methods
# --------------------
func set_player_team(player_id : int, team_id : int):
	if !_teams[team_id]:
		_create_team(team_id)
	
	_remove_from_team(player_id)
	_teams[team_id]["player_ids"].append(player_id)

# Private Methods
# --------------------
func _create_team(team_id : int):
	_teams[team_id] = {
		"player_ids" : [],
		"zones" : []
	}
	
func _remove_from_team(player_id : int):
	var team_id = PlayerManager.get_team_id(player_id)
	
	if _teams[team_id]:
		_teams[team_id]["player_ids"].erase(player_id)
