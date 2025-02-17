class_name PlayerCombatController;

var player: PlayerController;
var status: PlayerStatus;
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
		getTargetsInField(5, 0, 0);
	pass


func getTargetsInField(range : float, angleThresholdH : float, angleThresholdV : float) -> Dictionary:
	var targets = {};
	
	# get all current playerStatuses except for the current one.
	var playerStatuses = GameManager.inst.playerStatusesNotLocal;
	var playerIds = [];
	var playerPositions = [];
	
	for id in playerStatuses:
		playerIds.push_back(id);
		playerPositions.push_back((playerStatuses[id] as PlayerStatus).get_center_position());
	
	checkWhichTargetsAreInField(playerIds, playerPositions, range, angleThresholdH, angleThresholdV);
	
	return targets;
	pass;


func checkWhichTargetsAreInField(ids : Array, positions : Array, range : float, angleThresholdH : float, angleThresholdV : float) -> Array:
	var targets = [];
	var myPosition = player.get_center_position();
	for position in positions:
		var data = isTargetInField(myPosition, position, range, angleThresholdH, angleThresholdV);
		print(data.angle);
	return targets;
	
func isTargetInField(myPosition : Vector3, targetPosition : Vector3, range : float, angleThresholdH : float, angleThresholdV : float) -> R_TargetInFieldData:
	var data = R_TargetInFieldData.new();
	var myPositionH = Vector2(myPosition.x, myPosition.z);
	var targetPositionH = Vector2(targetPosition.x, targetPosition.z);
	var myDirection = player.get_model_forward_direction();
	var myDirectionH = Vector2(myDirection.x, myDirection.z);
	var angleH = (targetPositionH - myPositionH).normalized().dot(myDirectionH);
	var angleV = 1 - (targetPosition - myPosition).normalized().y;
	
	data.angle = (angleH + angleV) * .5;
	return data;
