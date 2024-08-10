extends Node

# Attributes
# --------------------

# Nodes
@onready var address_node = $Address
@onready var port_node = $Port
@onready var name_node = $PlayerName
@onready var player_list_node = $PlayerList
@onready var team_id_node = $Team

func _ready():
	Network.connect("player_data_updated", on_player_data_updated)
	Network.connect("connection_lost", on_connection_lost)
	
	# Add the player
	PlayerManager.add_player(multiplayer.get_unique_id(), "Player", 1)
	

# Remote Procedure Calls
# --------------------
@rpc("any_peer", "call_local")
func update_player_list():
	player_list_node.text = "Player list:\n"
	var players = PlayerManager.get_players()
	for i in players:
		player_list_node.text += (players[i]["player_name"] + " " + str(i) + "\n")

@rpc("any_peer", "call_local")
func start_game():
	# Set team of the player
	PlayerManager.set_player_team(multiplayer.get_unique_id(), int(team_id_node.text))
	
	# Load the playing scene
	var state_machine = get_node("/root/StateMachine")
	var data = {
	
	}
	state_machine.change_state(StateMachine.GAME_STATE.MAP_TEST, data)

# Signals
# --------------------

# Buttons
func _on_host_button_button_down():
	var server_port = port_node.text
	
	# Set player name
	PlayerManager.set_player_name(multiplayer.get_unique_id(), name_node.text)
	
	# Create a server
	Network.self_host_server(int(server_port))
	
	# Update lobby display
	# This is fine because server will always be already connected
	rpc("update_player_list")

func _on_join_button_button_down():
	var server_address = address_node.text
	var server_port = port_node.text
	
	# Set player name
	PlayerManager.set_player_name(multiplayer.get_unique_id(), name_node.text)
	
	# Join the server
	Network.join_server(server_address, int(server_port))

func _on_start_game_button_button_down():
	rpc("start_game")

# Network
func on_player_data_updated():
	# Update lobby display
	rpc("update_player_list")

func on_connection_lost():
	player_list_node.text = "Connection has been lost"
