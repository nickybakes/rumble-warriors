# Run.gd
extends PlayerState

var initialWallDragDirection : Vector2
var initialWallDragSpeed : float
var wallNormal : Vector3
var horizontalMoveAxis : Vector3
var verticalMoveAxis : Vector3
var climbingInput : Vector2
var climbingDirection : Vector3
var lastNonZeroClimbingInput := Vector2(1, 0)
var forceClimbingInput : Vector2
var forceClimbingTime : float
var forceClimbingInset : bool
var jumpSpeed : float
var jumpDirection : Vector2
var jumpCooldown : float
var jumpWarmup : float
var timeClimbing : float
var previousPosition : Vector3;

func _init():
	gravity_enabled = false
	rotate_weight = .3;
	rotation_mode = Enums.ROTATION_MODE.Chosen_Direction
	movement_mode = Enums.MOVEMENT_MODE.None
	
func enter(previousState : Enums.STATE, _msg := {}):
	previousPosition = player.position;
	forceClimbingTime = 0;
	jumpCooldown = 0;
	jumpSpeed = 0;
	timeClimbing = 0;
	player.grounded = false;
	player.fake_grounded = true;
	
	if(player.velocity == Vector3.ZERO):
		player.velocity = Vector3(0, -.1, 0);
		
	setWall(_msg["wallNormal"])
	calculateMovementAxis();
	calculateInitialWallSlide();
	
	player.animator.setAnimation(Enums.ANIMATION.ClimbSlide);
	
	stickToWall();
	pass
	
func exit():
	player.time_in_air = 0.0;
	player.fake_grounded = false;
	
func calculateInitialWallSlide():
	var dot = player.velocity.normalized().dot(horizontalMoveAxis);
	initialWallDragDirection = Vector2(dot, 1 - abs(dot));
	initialWallDragSpeed = (player.velocity * .5).length();
	
func setWall(normal: Vector3):
	wallNormal = normal;
	updateRotation(wallNormal)
	calculateMovementAxis()

func stickToWall(force = 4):
	#stick player to wall
	player.velocity = wallNormal * -force;
	for n in 4:
		player.move_and_slide();	

func updateRotation(normal: Vector3):
	player.chosen_rotation_direction = Vector2(-normal.x, -normal.z);
	
func calculateMovementAxis():
	horizontalMoveAxis = Vector3(wallNormal.z, 0, -wallNormal.x).normalized();
	verticalMoveAxis = horizontalMoveAxis.cross(wallNormal).normalized();
	
func moveAlongWall(direction: Vector2, speed: float, invertAnimationDirection = false):
	climbingInput = direction;
	player.animator.setAnimationVar0(direction.x * (-1 if invertAnimationDirection else 1));
	player.animator.setAnimationVar1(-direction.y * (-1 if invertAnimationDirection else 1));
	if(climbingInput != Vector2.ZERO):
		lastNonZeroClimbingInput = climbingInput;
	climbingDirection = (direction.x * horizontalMoveAxis + direction.y * verticalMoveAxis).normalized();
	player.velocity = climbingDirection * speed;	

func update(delta: float) -> void:
	var player_input = player.get_basic_input_dir().normalized();
	timeClimbing += delta;
	
	if forceClimbingTime > 0:
		forceClimbingTime -= delta
		if(forceClimbingInset):
			stickToWall(1.8)
		if(forceClimbingTime <= 0):
			stickToWall()
		moveAlongWall(forceClimbingInput, 6);
	elif initialWallDragSpeed > 0:
		initialWallDragSpeed = initialWallDragSpeed - (delta * 40);
		moveAlongWall(initialWallDragDirection, initialWallDragSpeed);
		if(initialWallDragSpeed <= 0):
			player.animator.setAnimation(Enums.ANIMATION.Climb);
	elif jumpSpeed > 0:
		if(jumpWarmup > 0):
			jumpWarmup -= delta;
			if(jumpWarmup <= 0):
				player.animator.setAnimation(Enums.ANIMATION.ClimbJump);
			moveAlongWall(jumpDirection, 0, true);
		elif(jumpSpeed > 0):
			jumpSpeed = max(jumpSpeed - (delta * 70), 0);
			if(jumpSpeed > 10):
				moveAlongWall(jumpDirection, jumpSpeed, false);
			else:
				player.animator.setAnimation(Enums.ANIMATION.ClimbSlide);
				moveAlongWall(jumpDirection, jumpSpeed, true);
				if(jumpSpeed <= 0):
					player.animator.setAnimation(Enums.ANIMATION.Climb);
					player.animator.setAnimationVar0(0, true);
					player.animator.setAnimationVar1(0, true);
	else:
		player.velocity = Vector3.ZERO;
		moveAlongWall(player_input, 6);
		jumpCooldown -= delta;
		
		if player.input_buffer.is_action_just_pressed(Enums.INPUT.Interact) and timeClimbing > .5:
			state_machine.transition_to(Enums.STATE.JumpFall);
			return
		
		if player.input_buffer.is_action_just_pressed(Enums.INPUT.Jump) and timeClimbing > .2 and jumpCooldown <= 0:
			if(player_input == Vector2.ZERO):
				player_input = Vector2.UP;
			jumpSpeed = 35;
			jumpCooldown = .2;
			jumpDirection = player_input;
			jumpWarmup = .1;
			player.animator.setAnimation(Enums.ANIMATION.ClimbSlide);
			return
		
	if(player.grounded and player_input):
		state_machine.transition_to(Enums.STATE.Run)
		return
		
	if(player.grounded and not player_input):
		state_machine.transition_to(Enums.STATE.Idle)
		return
	
func physics_update(delta: float) -> void:

		
	var wall_check = player.raycast_climb(climbingDirection, wallNormal);
	
	var outset = wall_check[0]
	var inset = wall_check[1]
	var origin = wall_check[2]
	
	if forceClimbingTime <= 0 and outset and outset.normal != wallNormal:
		var dist = origin.distance_squared_to(outset.position)
		if dist > 1.4:
			forceClimbingInset = false;			
			forceClimbingInput = lastNonZeroClimbingInput
			forceClimbingInput.y = 0;
			var dot = abs(wallNormal.dot(outset.normal));
			forceClimbingTime = max(.5 - dot, 0) * .7
			setWall(outset.normal)
			if(dot < .3):
				jumpSpeed = 0;
				player.animator.setAnimation(Enums.ANIMATION.Climb, true);
			else:
				stickToWall()
			return
			
	if forceClimbingTime <= 0 and inset and inset.normal != wallNormal:
		var dist1 = inset.position.distance_squared_to(player.position);
		var dist2 = (inset.position + inset.normal * .1).distance_squared_to(player.position + wallNormal * .1);
		var dot = abs(wallNormal.dot(inset.normal));
		if(dist1 > dist2):	
			forceClimbingInset = true;
			forceClimbingInput = lastNonZeroClimbingInput
			forceClimbingTime = .4
			setWall(inset.normal)
			if(dot < .5):
				jumpSpeed = 0;
				player.animator.setAnimation(Enums.ANIMATION.Climb, true);
			else:
				stickToWall()
			return

	if(forceClimbingTime <= 0 and (!outset or origin.distance_squared_to(outset.position) > 3) and !inset and climbingInput != Vector2.ZERO):
		if(climbingInput.y < -.5):
			state_machine.transition_to(Enums.STATE.Vault, {"direction": wallNormal})
		else:
			state_machine.transition_to(Enums.STATE.JumpFall)
