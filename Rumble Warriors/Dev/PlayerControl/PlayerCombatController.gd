class_name PlayerCombatController;

var player: PlayerController;
var state_machine: StateMachine;
var input_buffer: InputBuffer;


# Called when the node enters the scene tree for the first time.
func _init(playerController : PlayerController) -> void:
	player = playerController as PlayerController;
	state_machine = player.state_machine as StateMachine;
	input_buffer = player.input_buffer as InputBuffer;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta: float) -> void:
	if(input_buffer.is_action_just_pressed(Enums.INPUT.Strike)):
		print('awdawda');
	pass


func getTargetsInField() -> void:
	
	pass;
