extends Node

# Attributes
# --------------------

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

func set_up():
	pass

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
