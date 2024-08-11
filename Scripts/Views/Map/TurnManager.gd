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
var base_time_limit : float = 60.0
var time_limit : float = base_time_limit
var time_spent_in_turn : float = 0

# Order related
var order : Array

# Setup Functions
# --------------------
func set_up():
	# Set up for the host
	if multiplayer.get_unique_id() == 1:
		set_for_host()
	
func set_for_host():
	# Figure out the order of turns
	for i in PlayerManager.get_players().keys():
		# Ignore spectators
		print ("TEAM ID: %s" %[PlayerManager.get_team_id(i)])
		if PlayerManager.get_team_id(i) > 0:
			order.append(i)
			
	# For now order players by random
	# In future use more balanced methods
	order.shuffle()

	print ("The array in question: %s" % [order])
	print ("Players total: %s" %[PlayerManager.get_players().keys().size()])


# Proccess Functions
# --------------------
func _process(delta : float):
	handle_time_calculation(delta)
	
func handle_time_calculation(delta : float):
	time_spent_in_turn += delta

func handle_forced_turn_change():
	if set_timer_type != TIMER_TYPE.DISABLED:
		if time_spent_in_turn >= time_limit:
			start_next_turn()


func start_next_turn():
	pass
