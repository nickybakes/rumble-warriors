class_name PlayerCombatController;

var player: PlayerController;
var animator : PlayerAnimator;
var status: PlayerStatus;
var state_machine: StateMachine;
var input_buffer: InputBuffer;

var currentAttack : R_Attack;


# Called when the node enters the scene tree for the first time.
func _init(playerController : PlayerController) -> void:
	player = playerController as PlayerController;
	animator = playerController.animator as PlayerAnimator;
	state_machine = player.state_machine as StateMachine;
	input_buffer = player.input_buffer as InputBuffer;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta: float) -> void:
	if(state_machine.time_in_state > currentAttack.total_time()):
		if(player.grounded):
			state_machine.transition_to(Enums.STATE.Idle);
		else:
			state_machine.transition_to(Enums.STATE.JumpFall);
	
	pass

func startAttack():
	state_machine.transition_to(Enums.STATE.Attack);
	currentAttack = CombatManager.inst.get_attack(Enums.ATTACK.BasicStrike_01);
	animator.setAttackAnimation(currentAttack.attackAnimation);
	player.requested_move_direction = Vector3.ZERO;
	getTargetsInField(25, 0, 0, 0);
	pass;

func checkInputs(delta: float) -> bool:
	if(input_buffer.is_action_just_pressed(Enums.INPUT.Strike)):
		startAttack();
		return true;
	#if(input_buffer.is_action_just_pressed(Enums.INPUT.Grab)):
		#if(player.grounded):
			#print("ground grab");
			#getTargetsInField(25, 0, 0, 0);
		#else:
			#print("slam");
		#return true;
	return false;

func getTargetsInField(squaredRange : float, angleThresholdH : float, angleThresholdV : float, yOffset : float) -> Dictionary:
	var targets = {};
	
	# get all current playerStatuses except for the current one.
	var playerStatuses = GameManager.inst.playerStatusesNotLocal;
	var playerIds = [];
	var playerPositions = [];
	
	for id in playerStatuses:
		playerIds.push_back(id);
		playerPositions.push_back((playerStatuses[id] as PlayerStatus).get_center_position());
	
	checkWhichTargetsAreInField(playerIds, playerPositions, squaredRange, angleThresholdH, angleThresholdV, 0);
	
	return targets;
	pass;


func checkWhichTargetsAreInField(ids : Array, positions : Array, squaredRange : float, angleThresholdH : float, angleThresholdV : float, yOffset : float) -> Array:
	var targets = [];
	var myPosition = player.get_center_position();
	for position in positions:
		var data = isTargetInField(myPosition, position, squaredRange, angleThresholdH, angleThresholdV, 0);
		print(data);
	return targets;
	
func isTargetInField(myPosition : Vector3, targetPosition : Vector3, squaredRange : float, angleThresholdH : float, angleThresholdV : float, yOffset : float) -> R_TargetInFieldData:
	var data = R_TargetInFieldData.new();
	var myPositionH = Vector2(myPosition.x, myPosition.z);
	var targetPositionH = Vector2(targetPosition.x, targetPosition.z);
	var myDirection = player.get_model_forward_direction();
	var myDirectionH = Vector2(myDirection.x, myDirection.z);
	var angleH = (targetPositionH - myPositionH).normalized().dot(myDirectionH);
	var angleV = 1 - (targetPosition - (myPosition + Vector3(0, yOffset, 0))).normalized().y;
	
	data.angle = (angleH + angleV) * .5;
	data.squaredDistance = myPosition.distance_squared_to(targetPosition);
	data.inField = angleH > angleThresholdH and angleV > angleThresholdV and data.squaredDistance < squaredRange;
	return data;
