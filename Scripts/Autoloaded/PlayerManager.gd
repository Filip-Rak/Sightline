extends Node

# Attributes
# --------------------

# Player data
var players = {}

# Player data template
# PLAYER_ID:
# 	'player_name': string
# 	'team_id' : int


# Setters
# --------------------
func add_player(player_id : int, player_name : String, team_id : int):
	players[player_id] = {
		"player_name": player_name,
		"team_id": team_id
	}

func change_id(previous_id : int, new_id : int): 
	if players.has(new_id):
		# Switch the players
		var buffer : Dictionary = players[new_id]
		players[new_id] = players[previous_id]
		players[previous_id] = buffer
	else:
		# Assign the player to new_id, delete the old one
		players[new_id] = players[previous_id]
		players.erase(previous_id)

func set_player(id : int, data : Dictionary):
	players[id] = data

func set_player_name(id : int, player_name : String):
	players[id]["player_name"] = player_name

func set_player_team(player_id : int, team_id : int):
	players[player_id]["team_id"] = team_id

func drop_player(player_id : int) -> bool:
	if players.has(player_id):
		players.erase(player_id)
		return true
		
	return false

# Getters
# --------------------
func get_players() -> Dictionary:
	return players

func get_player(id : int) -> Dictionary:
	return players[id]

func is_player(id : int) -> bool:
	return players.has(id)
