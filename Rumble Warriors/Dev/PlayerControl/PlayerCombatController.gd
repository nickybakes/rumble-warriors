class_name PlayerCombatController;

var player: PlayerController;
var animator : PlayerAnimator;
var status: PlayerStatus;
var state_machine: StateMachine;
var input_buffer: InputBuffer;

var currentAttack : R_Attack;
var currentVictimState : R_VictimState;

var attackDirection : Vector3;
var attackDirectionSideways : Vector3;
#Vector3(wallNormal.z, 0, -wallNormal.x).normalized()
var currentTrackingTarget : PlayerStatus;


# Called when the node enters the scene tree for the first time.
func _init(playerController : PlayerController) -> void:
	player = playerController as PlayerController;
	animator = playerController.animator as PlayerAnimator;
	state_machine = player.state_machine as StateMachine;
	input_buffer = player.input_buffer as InputBuffer;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func updateAttack(delta: float) -> void:
	if(state_machine.time_in_state > currentAttack.total_time()):
		if(player.grounded):
			state_machine.transition_to(Enums.STATE.Idle);
		else:
			state_machine.transition_to(Enums.STATE.JumpFall);
		return;
	
	if(checkInputsDuringAttack(delta)):
		return;
		
	if(currentTrackingTarget != null):
		if(state_machine.time_in_state < currentAttack.windupTime):
			var direction = (currentTrackingTarget.positionNetworked - player.position).normalized();
			var goalPosition = currentTrackingTarget.positionNetworked - direction;
			var distance = player.position.distance_to(goalPosition);
			var timeLeft = currentAttack.windupTime - state_machine.time_in_state
			if(timeLeft > 0.0):
				var speed = distance/timeLeft;
				player.customSpeed = speed;
				player.requested_move_direction = direction;
		else:
			player.requested_move_direction = Vector3.ZERO;
			player.velocity = Vector3.ZERO;
	else:
		var velocitySample = currentAttack.sample_velocity(state_machine.time_in_state);
		var horizontalMovement = (velocitySample.x * attackDirectionSideways + velocitySample.z * attackDirection);
		player.velocity = Vector3(horizontalMovement.x, velocitySample.y, horizontalMovement.z);
			
	
	pass

func updateVictim(delta: float) -> void:
	
	pass;

func startAttack(attack : Enums.ATTACK):
	if(attack == Enums.ATTACK.None):
		return;
		
	state_machine.transition_to(Enums.STATE.Attack);
	currentAttack = InteractionsManager.inst.get_attack(attack);
	animator.setAnimation(currentAttack.attackAnimation);
	player.requested_move_direction = Vector3.ZERO;
	player.velocity = Vector3.ZERO;
	currentTrackingTarget = null;
	if(player.get_requested_move_direction()):
		attackDirection = player.get_requested_move_direction();
	else:
		attackDirection = player.get_model_forward_direction();
	attackDirectionSideways = Vector3(-attackDirection.z, 0, attackDirection.x).normalized();
	attackHitboxRegister(currentAttack);
	if(currentTrackingTarget != null):
		state_machine.state.movement_mode = Enums.MOVEMENT_MODE.Velocity;
	else:
		state_machine.state.movement_mode = Enums.MOVEMENT_MODE.None;
		player.requested_move_direction = Vector3.ZERO;
		
	pass;
	
func startElbowDrop():
	state_machine.transition_to(Enums.STATE.ElbowDrop);
	currentTrackingTarget = null;
	#attackHitboxRegister(currentAttack);

func checkInputsDuringAttack(delta: float) -> bool:
	if(currentAttack.nextAttackInCombo != Enums.ATTACK.None && state_machine.time_in_state >= currentAttack.combo_start_total_time() && input_buffer.is_action_just_pressed(Enums.INPUT.Strike)):
		startAttack(currentAttack.nextAttackInCombo);
		return true;
	return false;

func checkInputs(delta: float) -> bool:
	if(input_buffer.is_action_just_pressed(Enums.INPUT.Strike)):
		if(player.grounded):
			startAttack(Enums.ATTACK.BasicStrike_01);
			return true;
		else:
			startElbowDrop();
			return true;
	#if(input_buffer.is_action_just_pressed(Enums.INPUT.Grab)):
		#if(player.grounded):
			#print("ground grab");
			#getTargetsInField(25, 0, 0, 0);
		#else:
			#print("slam");
		#return true;
	return false;

func attackHitboxRegister(attack : R_Attack):
	var targets = getTargetsInField(attack.range, attack.angleThresholdHorizontal, attack.angleThresholdVertical, attack.heightOffset);
	var currentBestPlayerTarget: R_TargetData = null;
	
	for playerTarget in targets.players:
		if(currentBestPlayerTarget == null or currentBestPlayerTarget.trackingScore < playerTarget.trackingScore):
			currentBestPlayerTarget = playerTarget;
		pass;
		
	if(currentBestPlayerTarget != null):
		currentTrackingTarget = GameManager.inst.playerStatuses[currentBestPlayerTarget.id];
	print("BEST TRACKING: ", currentBestPlayerTarget);
		
func getTargetsInField(range : float, angleThresholdH : float, angleThresholdV : float, yOffset : float) -> R_TargetList:
	var targets = R_TargetList.new();
	
	# get all current playerStatuses except for the current one.
	var playerStatuses = GameManager.inst.playerStatusesNotLocal;
	var playerIds = [];
	var playerPositions = [];
	
	for id in playerStatuses:
		playerIds.push_back(id);
		playerPositions.push_back((playerStatuses[id] as PlayerStatus).get_center_position());
	
	var hitPlayerTargets = checkWhichTargetsAreInField(playerIds, playerPositions, range, angleThresholdH, angleThresholdV, 0);
	targets.players = hitPlayerTargets;

	return targets;
	pass;


func checkWhichTargetsAreInField(ids : Array, positions : Array, range : float, angleThresholdH : float, angleThresholdV : float, yOffset : float) -> Array[R_TargetData]:
	var targets = [] as Array[R_TargetData];
	var myPosition = player.get_center_position();
	for index in ids.size():
		var data = isTargetInField(myPosition, positions[index], range, angleThresholdH, angleThresholdV, 0);
		if(data.inField):
			data.id = ids[index];
			data.trackingScore = getTargetTrackingScore(data, range);
			targets.push_back(data);
			
	return targets;

func getTargetTrackingScore(target : R_TargetData, range : float) -> float:
	var score = (1.0 - (target.distance/range)) + target.angle;
	return score;

func isTargetInField(myPosition : Vector3, targetPosition : Vector3, range : float, angleThresholdH : float, angleThresholdV : float, yOffset : float) -> R_TargetData:
	var data = R_TargetData.new();
	var myPositionH = Vector2(myPosition.x, myPosition.z);
	var targetPositionH = Vector2(targetPosition.x, targetPosition.z);
	var myDirectionH = Vector2(attackDirection.x, attackDirection.z);
	var angleH = (targetPositionH - myPositionH).normalized().dot(myDirectionH);
	var angleV = 1 - abs((targetPosition - (myPosition + Vector3(0, yOffset, 0))).normalized().y);
	
	data.angle = (angleH + angleV) * .5;
	data.distance = myPosition.distance_to(targetPosition);
	var angleThresholdAdjust = (1.0 - (data.distance / range)) * .6;
	data.inField = angleH > (angleThresholdH - angleThresholdAdjust) and angleV > (angleThresholdV - angleThresholdAdjust) and data.distance < range;
	return data;
	
func isTargetInFieldBelow(myPosition : Vector3, targetPosition : Vector3, range : float, angleThresholdH : float, angleThresholdV : float) -> R_TargetData:
	var data = R_TargetData.new();
	var myPositionH = Vector2(myPosition.x, myPosition.z);
	var targetPositionH = Vector2(targetPosition.x, targetPosition.z);
	var myDirection = player.get_model_forward_direction();
	var myDirectionH = Vector2(myDirection.x, myDirection.z);
	var angleH = (targetPositionH - myPositionH).normalized().dot(myDirectionH);
	var angleV = 1 - abs((targetPosition - myPosition).normalized().y);
	
	data.angle = (angleH + angleV) * .5;
	data.distance = myPosition.distance_to(targetPosition);
	var angleThresholdAdjust = (1.0 - (data.distance / range)) * .6;
	data.inField = angleH > (angleThresholdH - angleThresholdAdjust) and angleV > (angleThresholdV - angleThresholdAdjust) and data.distance < range;
	return data;
