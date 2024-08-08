extends Node

# Attributes
# --------------------

# Player data
var players = {}

# Reference to the map stored for greater accesibility over the network
var tile_matrix : Array

# Connection
var peer : ENetMultiplayerPeer
var server_port : int = 135
var server_address = "127.0.0.1"
const COMPRESSION := ENetConnection.COMPRESS_RANGE_CODER

# Ready Functions
# --------------------
func _ready():
	# Server and connected players - side signals
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	
	# Client - side signals
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	multiplayer.server_disconnected.connect(server_disconnected)
	
	# Add custom signals
	add_user_signal("player_data_updated")
	add_user_signal("connection_lost")
	
# Multiplayer Signal Functions
func peer_connected(id):
	print("ID: %s connected" % [id])
	
func peer_disconnected(id):
	print("ID: %s disconnected" % [id])
	
	# Delete disconnected player's information
	if Network.players.has(id):
		Network.players.erase(id)
	
	# Host ID is equal to 1
	if id == 1: 
		print("Host disconnected, connection lost")
		emit_signal("connection_lost")
		reset_multiplayer_state()
	else:
		rpc("distribute_player_information")
		emit_signal("player_data_updated")
	
func connected_to_server():
	print("Connection to server succesfull")
	
	# Send the data to the server
	rpc_id(1, "send_player_information", players[multiplayer.get_unique_id()], multiplayer.get_unique_id())
	
func connection_failed():
	print("Connection to server failed")

func server_disconnected():
	print("Lost connection to the server")

# Connection Functions
# --------------------
func self_host_server(port : int, player_data : Dictionary):
	if port:
		server_port = port
	if setup_multiplayer_peer(true):
		players[multiplayer.get_unique_id()] = player_data
		print("Server is active")

func join_server(address: String, port: int, player_data: Dictionary):
	if port:
		server_port = port
	if address:
		server_address = address
	if setup_multiplayer_peer(false):
		players[multiplayer.get_unique_id()] = player_data
		
func setup_multiplayer_peer(is_server: bool):
	peer = ENetMultiplayerPeer.new()
	
	if is_server:
		var error = peer.create_server(server_port)
		if error != OK:
			print("Couldn't create a server: " + str(error))
			return false
	else:
		peer.create_client(server_address, server_port)
		
	peer.get_host().compress(COMPRESSION)
	multiplayer.set_multiplayer_peer(peer)
	return true

func reset_multiplayer_state():
	print("Resetting multiplayer state...")
	
	# Disconnect the peer
	# if peer:
		# peer.close_connection()
		
	# Reset the multiplayer peer
	multiplayer.multiplayer_peer = null
	
	# Clear player data
	players.clear()

# Remote Procedure Calls
# --------------------

# GameManager
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

@rpc("any_peer")
func send_player_information(player_data : Dictionary, id : int, last_one : bool = false):
	# Send data to server
	if !players.has(id):
		players[id] = player_data
		
		# Server sends data to all the clients
		if multiplayer.is_server():
			rpc("distribute_player_information")
	
	# Inform all the hosts that their information is up to date
	if last_one:
		emit_signal("player_data_updated")

@rpc("any_peer", "call_local")
func distribute_player_information():
	var player_keys = players.keys()
	var last_index = player_keys.size() - 1
	
	for index in player_keys.size():
		var player_id = player_keys[index]
		var player_data = players[player_id]
		
		# If this is the last player, set the last_one flag to true
		if index == last_index:
			rpc("send_player_information", player_data, player_id, true)
		else:
			rpc("send_player_information", player_data, player_id)
# Setters
# --------------------
func set_tile_matrix(tiles):
	tile_matrix = tiles
