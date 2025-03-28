# Generic state machine. Initializes states and delegates engine callbacks
# (_physics_process, _unhandled_input) to the active state.
class_name StateMachine
extends Node



# Emitted when transitioning to a new state.
signal transitioned(state_name)

# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
@export var initial_state := NodePath()

# The current active state. At the start of the game, we get the `initial_state`.
@onready var state: PlayerState = get_node(initial_state)

var time_in_state:= 0.0

var previousState: Enums.STATE = Enums.STATE.Idle

var currentState: Enums.STATE = Enums.STATE.Idle

# If true, then only call the dummy methods for state enter/exit.
# The dummy methods only control cosmetic things like visuals/audio
# aka when to spawn particles
var dummyOnly := false;


func _ready() -> void:
	await owner.ready
	# The state machine assigns itself to the State objects' state_machine property.
	for child in get_children():
		child.state_machine = self
	state.enter(previousState)


# The state machine subscribes to node callbacks and delegates them to the state objects.
func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func update(delta: float) -> void:
	time_in_state += delta
	state.update(delta)


func physics_update(delta: float) -> void:
	state.physics_update(delta)


# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `msg` dictionary to pass to the next state's enter() function.
func transition_to(target_state: Enums.STATE, msg: Dictionary = {}) -> void:
	var state_name : String = Enums.STATE.keys()[target_state]
	
	# Safety check, you could use an assert() here to report an error if the state name is incorrect.
	# We don't use an assert here to help with code reuse. If you reuse a state in different state machines
	# but you don't want them all, they won't be able to transition to states that aren't in the scene tree.
	if not has_node(state_name):
		return
		
	#print(str(Time.get_ticks_msec()/1000.0) + " " + state_name)

	previousState = currentState

	state.exit()
	state = get_node(state_name)
	state.enter(previousState, msg)
	
	time_in_state = 0.0

	currentState = target_state
	
	emit_signal("transitioned", state.name)
