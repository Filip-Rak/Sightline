extends Control

# Attributes
# --------------------

# Connection
var peer : ENetMultiplayerPeer
const PORT : int = 135
const ADDRESS = "127.0.0.1"
const COMPRESSION := ENetConnection.COMPRESS_RANGE_CODER

# Nodes
@onready var name_node = $PlayerName
@onready var player_list_node = $PlayerList

# Ready Functions
# --------------------
func _ready():
	# Server and connected players - side signals
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	
	# Client - side signals
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
# Multiplayer Signal Functions
func peer_connected(id):
	print("ID: %s connected" % [id])
	
func peer_disconnected(id):
	print("ID: %s disconnected" % [id])
	
	# Delete disconnected player's information
	if PlayerManager.players.has(id):
		PlayerManager.players.erase(id)
		
	rpc("distribute_player_information")
	rpc("update_player_list")
	
func connected_to_server():
	print("Connection to server succesfull")
	rpc_id(1, "send_player_information_to_server", name_node.text, multiplayer.get_unique_id())
	
func connection_failed():
	print("Connection to server failed")
	
# Button Signal Functions
# --------------------
func _on_host_button_button_down():
	# Creating a client
	peer = ENetMultiplayerPeer.new()
	
	# CLient makes a server
	var error = peer.create_server(PORT)
	if error != OK:
		print ("Couldnt create a server: " + str(error))
		return
		
	# Set a compression type
	peer.get_host().compress(COMPRESSION)
	
	# Set the hosting peer as client's peer
	multiplayer.set_multiplayer_peer(peer)
	print ("Server is active")
	
	# Send host information to players
	send_player_information_to_server(name_node.text, multiplayer.get_unique_id())
	
func _on_join_button_button_down():
	# Create a new client
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ADDRESS, PORT)
	
	# Set compression same to host's 
	peer.get_host().compress(COMPRESSION)
	
	# Set user's peer as created peer
	multiplayer.set_multiplayer_peer(peer)

func _on_start_game_button_button_down():
	rpc("start_game")
	
# Remote Procedure Calls
# --------------------

@rpc("any_peer", "call_local")
func start_game_alt():
	# Load the playing scene
	var scene = load("res://Scenes/Main.tscn").instantiate()
	get_tree().root.add_child(scene)
	
	# Hide the lobby UI
	self.hide()
	
@rpc("any_peer", "call_local")
func start_game():
	# Load the playing scene
	var state_machine = get_node("/root/StateMachine")
	var data = {

	}
	state_machine.change_state(StateMachine.GAME_STATE.MAP_TEST, data)
	
@rpc("any_peer")
func send_player_information_to_server(player_name : String, id : int):
	# Send data to server
	if !PlayerManager.players.has(id):
		PlayerManager.players[id] = {
			"player_name": player_name,
			"id": id,
		}
		
	# Server sends data to all the clients
		if multiplayer.is_server():
			rpc("distribute_player_information")
	
	# Update lobby display
	rpc("update_player_list")
	
@rpc("any_peer", "call_local")
func distribute_player_information():
	for i in PlayerManager.players:
		rpc("send_player_information_to_server", PlayerManager.players[i]["player_name"], i)
	
@rpc("any_peer", "call_local")
func update_player_list():
	player_list_node.text = "Player list:\n"
	for i in PlayerManager.players:
		player_list_node.text += (PlayerManager.players[i]["player_name"] + "\n")
	
	
