extends Node

# Attributes
# --------------------

class_name Turn_Manager

# Time related
enum TIMER_TYPE{
	# No timer
	DISABLED,
	
	# Every turn will have the same time limit
	FIXED,
	
	# Each turn can be longer or shorter based on in-game factors
	# To be implemented later
	DYNAMIC
}

var set_timer_type : TIMER_TYPE = TIMER_TYPE.DISABLED
var base_time_limit : float = 10.0
var time_limit : float = base_time_limit
var time_spent_in_turn : float = 0
var current_turn : int = 0

# Order related
var order : Array
var current_index = 0

# Other scripts
var game_manager : Game_Manager

# For clients
var current_turn_player_id : int

func _ready():
	# Connect signals
	multiplayer.peer_disconnected.connect(peer_disconnected)
	
	# Add custom signals
	add_user_signal("new_game_turn")

# Setup Functions
# --------------------
func set_up(gm : Game_Manager):
	# Setup for everyone
	common_setup(gm)
	
	# Set up for the host
	if multiplayer.get_unique_id() == 1: set_for_host()
	
func common_setup(gm : Game_Manager):
	game_manager = gm

func set_for_host():
	# Figure out the order of turns
	for id in PlayerManager.get_players().keys():
		# Ignore spectators
		if PlayerManager.get_team_id(id) <= 0: continue
		# Ignore disconnected players
		if !PlayerManager.get_player_connected(id): continue
		
		order.append(id)
			
	# For now order players by random
	# In future use more balanced methods
	order.shuffle()

	print ("Turn order: %s" % [order])

# Proccess Functions
# --------------------
func _process(delta : float):
	handle_time_calculation(delta)
	
	if multiplayer.get_unique_id() == 1:
		handle_forced_turn_change()
	
func handle_time_calculation(delta : float):
	time_spent_in_turn += delta

func handle_forced_turn_change():
	if set_timer_type != TIMER_TYPE.DISABLED:
		if time_spent_in_turn >= time_limit:
			start_new_turn()

# External Control Functions
# --------------------

func peer_disconnected(id : int):
	# Do this in GlobalSingalHandler
	if id == 1:
		get_tree().quit()
	
	# Only on host
	if multiplayer.get_unique_id() == 1:
		if id == order[current_index]:
			start_new_turn()
			current_index -= 1
		elif id <= order[current_index]:
			current_index -= 1
			
		order.erase(id)

func begin_game():
	if multiplayer.is_server():
		start_new_turn()

func try_skip_turn():
	# For host
	if multiplayer.is_server():
		request_turn_skip(multiplayer.get_unique_id())
	else:
		# Politely ask the host to skip your turn (host will check your id)
		rpc_id(1, "request_turn_skip", multiplayer.get_unique_id())

# Internal Control Functions
# --------------------
func start_new_turn():
	# Calculate the time
	if set_timer_type != TIMER_TYPE.DISABLED:
		# Later use function for dynamic calculation instead
		time_limit = base_time_limit
		
	# Disable current turn
	rpc("end_player_turn", order[current_index])
	
	# Update turn num
	if current_index == 0: 
		current_turn += 1
		emit_signal("new_game_turn")
	
	# Update order index
	current_index += 1
	current_index %= order.size()
	
	# Inform clients with new turn details
	rpc("distribute_turn_data", order[current_index], time_limit, current_turn)
	
	# Enable player's turn
	rpc("start_player_turn", order[current_index])

# Remote Procedure Calls
# --------------------
@rpc("any_peer", "call_remote")
func request_turn_skip(caller_id : int):
	if caller_id == order[current_index]:
		start_new_turn()

@rpc("any_peer", "call_local")
func start_player_turn(player_id : int):
	if multiplayer.get_unique_id() == player_id:
		game_manager.enable_turn()

@rpc("any_peer", "call_local")
func end_player_turn(player_id : int):
	if multiplayer.get_unique_id() == player_id:
		game_manager.disable_turn()
	
@rpc("any_peer", "call_local")
func distribute_turn_data(player_id : int, given_time : float, turn_num : int):
	time_limit = given_time
	time_spent_in_turn = 0
	current_turn_player_id = player_id
	current_turn = turn_num
	game_manager.game_ui.update_turn_ui(player_id, given_time, turn_num)
	pass

# Getters
# --------------------
func get_turn_num() -> int:
	return current_turn
