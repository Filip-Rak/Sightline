extends Node

# Attributes
# --------------------

# Nodes
@onready var address_node = $Address
@onready var port_node = $Port
@onready var name_node = $PlayerName
@onready var player_list_node = $PlayerList

func _ready():
	Network.connect("player_data_updated", on_player_data_updated)
	Network.connect("connection_lost", on_connection_lost)

# Remote Procedure Calls
# --------------------
@rpc("any_peer", "call_local")
func update_player_list():
	player_list_node.text = "Player list:\n"
	for i in Network.players:
		player_list_node.text += (Network.players[i]["player_name"] + " " + str(i) + "\n")

@rpc("any_peer", "call_local")
func start_game():
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
	var player_data = {
		"player_name": name_node.text
	}
	
	# Create a server
	Network.self_host_server(int(server_port), player_data)
	
	# Update lobby display
	# This is fine because server will always be already connected
	rpc("update_player_list")

func _on_join_button_button_down():
	var server_address = address_node.text
	var server_port = port_node.text
	var player_data = {
		"player_name": name_node.text
	}
	
	# Join the server
	Network.join_server(server_address, int(server_port), player_data)

func _on_start_game_button_button_down():
	rpc("start_game")

# Network
func on_player_data_updated():
	# Update lobby display
	rpc("update_player_list")

func on_connection_lost():
	player_list_node.text = "Connection has been lost"
