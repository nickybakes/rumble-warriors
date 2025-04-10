extends CharacterBody3D
class_name PlayerController

#PlayerController is the object that reacts to player input.
#It will control player's state, movement, etc.

const botAttachmentPrefab = preload("res://Dev/PlayerControl/Bot Attachment.tscn");
const hudPrefab = preload("res://Dev/PlayerControl/Player HUD.tscn");

const GRAVITY = 45.0
const SPEED = 11.0
const GROUND_CONTROL = 75.0
const AIR_CONTROL = .5
const AIR_SPEED_CHANGE_AMOUNT = 30.0
const JUMP_HEIGHT = 3.4
const FALL_GRAVITY_MULTI = 1.7
const ROAD_RUNNER_TIME_MAX = 0.12

var customSpeed = 0.0;
var customGravityMultiplier = 1.0;

var input_buffer : InputBuffer;
var combat_controller: PlayerCombatController;


var requested_move_direction := Vector3(0, 0, 0);
var last_non_zero_horizontal_velocity := Vector3(0, 0, -1)
var last_non_zero_requested_move_direction := Vector3(0, 0, -1)

var chosen_rotation_direction := Vector2(0, -1)

var time_in_air := 0.0
var time_grounded := 0.0
var prev_time_in_air := 0.0
var prev_time_grounded := 0.0
var grounded := false
var fake_grounded := false
var was_grounded := false
var road_runner_jump_available := false

var mouse_sensitivity := .001
var gamepad_sensitivity := .05
var twist_input := 0.0
var pitch_input := 0.0

var model: Node3D;
var state_machine: StateMachine;
var animator : PlayerAnimator;
var camera_twist: Node3D;
var camera_pitch: Node3D;
var hud: PlayerHUD;

var isBot := false;
var id : int;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func setup(_bot : bool, _id : int):
	isBot = _bot;
	id = _id;
	if(_bot):
		input_buffer = InputBufferBot.new();
		$CameraTwist.queue_free();
		var attachment = botAttachmentPrefab.instantiate();
		add_child(attachment);
	else:
		input_buffer = InputBufferPlayer.new();
		hud = hudPrefab.instantiate() as PlayerHUD;
		add_child(hud, true);
		
		
	camera_twist = $CameraTwist;
	camera_pitch = $CameraTwist/CameraPitch;
	
	model = $Model;
	state_machine = $StateMachine;
	animator = $"Model/ModelPitch/Player Animator";
	combat_controller = PlayerCombatController.new(self);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	state_machine.update(delta);
	
	if(!isBot):
		if(Input.is_action_just_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif(Input.is_action_just_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
		twist_input = twist_input + Input.get_axis("look_right", "look_left") * gamepad_sensitivity
		pitch_input = pitch_input + Input.get_axis("look_down", "look_up") * gamepad_sensitivity
			
		camera_twist.rotate_y(twist_input)
		camera_pitch.rotate_x(pitch_input)
		camera_pitch.rotation.x = clamp(camera_pitch.rotation.x, deg_to_rad(-60), deg_to_rad(45))
		
		twist_input = 0.0
		pitch_input = 0.0
	
	pass
	
func _unhandled_input(event: InputEvent) -> void:	
	if event is InputEventMouseMotion and !isBot:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity
	
	
func current_speed() -> float:
	match(state_machine.state.speed_mode):
		Enums.SPEED_MODE.Multiplied:
			return SPEED * state_machine.state.speed_multiplier;
		Enums.SPEED_MODE.Custom:
			return customSpeed;
	return 0;
	
func get_basic_input_dir() -> Vector2:
	return input_buffer.get_movement_direction();
	
func get_requested_move_direction() -> Vector3:
	var input_dir = get_basic_input_dir();
	if(isBot):
		return Vector3(input_dir.x, 0, input_dir.y).normalized();
	else:
		var direction = (camera_twist.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		return direction;
	
func get_top_down_speed() -> float:
	return get_top_down_velocity().length();
	
func get_top_down_velocity() -> Vector2:
	return Vector2(velocity.x, velocity.z)
	
func get_horizontal_velocity() -> Vector3:
	return Vector3(velocity.x, 0, velocity.z)
	
func get_model_forward_direction() -> Vector3:
	return -model.transform.basis.z;

func get_center_position() -> Vector3:
	return position + Vector3.UP;

func _physics_process(delta: float) -> void:
	input_buffer.update(delta);
	state_machine.physics_update(delta);
	
	if(get_top_down_velocity()):
		last_non_zero_horizontal_velocity = get_horizontal_velocity()
	var player_move_input = get_requested_move_direction()
	if(player_move_input):
		last_non_zero_requested_move_direction = player_move_input
	was_grounded = grounded
	grounded = is_on_floor()
	jump_and_gravity(delta)
	control_movement(delta)
	match(state_machine.state.rotation_mode):
		Enums.ROTATION_MODE.Velocity:
			control_rotation_velocity(delta)
		Enums.ROTATION_MODE.Chosen_Direction:
			control_rotation_chosen_direction(delta)
	
	move_and_slide()
	
func control_movement(delta: float) -> void:
	if(state_machine.state.movement_mode == Enums.MOVEMENT_MODE.None):
		return;
	
	if(grounded or fake_grounded):
		if not requested_move_direction:
			var decelAmount = 100
			var topDownVelocity = get_top_down_velocity()
			var currentTopDownSpeed = topDownVelocity.length()
			if(currentTopDownSpeed > .2):
				var currentVelDirection : Vector2 = topDownVelocity/currentTopDownSpeed
				currentTopDownSpeed = move_toward(currentTopDownSpeed, 0, decelAmount * delta)
				velocity.x = currentVelDirection.x * currentTopDownSpeed
				velocity.z = currentVelDirection.y * currentTopDownSpeed
			else:
				velocity.x = 0
				velocity.z = 0
		else:
			var decelAmount = 70
			var topDownVelocity = get_top_down_velocity()
			var currentTopDownSpeed = topDownVelocity.length()
			if(currentTopDownSpeed > current_speed()):
				var currentVelDirection : Vector2 = topDownVelocity/currentTopDownSpeed
				currentTopDownSpeed = move_toward(currentTopDownSpeed, 0, decelAmount * delta)
				velocity.x = currentVelDirection.x * currentTopDownSpeed
				velocity.z = currentVelDirection.y * currentTopDownSpeed
			else:
				velocity.x = move_toward(velocity.x, requested_move_direction.x * current_speed(), GROUND_CONTROL * delta)
				velocity.z = move_toward(velocity.z, requested_move_direction.z * current_speed(), GROUND_CONTROL * delta)
				
		if(abs(velocity.x) < .5): velocity.x = 0
		if(abs(velocity.z) < .5): velocity.z = 0
		
	else:
		var decelAmount = 10
		var topDownVelocity = get_top_down_velocity()
		var currentTopDownSpeed = topDownVelocity.length()
		var currentVelDirection : Vector2 = topDownVelocity/currentTopDownSpeed
		if(currentVelDirection.dot(Vector2(requested_move_direction.x, requested_move_direction.z)) > .9 and currentTopDownSpeed > current_speed()):
			currentTopDownSpeed -= decelAmount * delta
			velocity.x = currentVelDirection.x * currentTopDownSpeed
			velocity.z = currentVelDirection.y * currentTopDownSpeed
		else:
			var differenceX = velocity.x - (current_speed() * requested_move_direction.x)
			var differenceZ = velocity.z - (current_speed() * requested_move_direction.z)
			var speedDecayDirection = Vector2(differenceX, differenceZ) / current_speed()
			if(current_speed() == 0):
				speedDecayDirection = Vector2.ZERO
			velocity.x = velocity.x - speedDecayDirection.x * AIR_SPEED_CHANGE_AMOUNT * delta
			velocity.z = velocity.z - speedDecayDirection.y * AIR_SPEED_CHANGE_AMOUNT * delta

func control_rotation_velocity(delta: float) -> void:
	var top_down_velocity = get_top_down_velocity()
	if top_down_velocity:
		top_down_velocity = top_down_velocity.normalized()
		var target_rotation = atan2(-top_down_velocity.x, -top_down_velocity.y)
		var rotation = lerp_angle(model.rotation.y, target_rotation, state_machine.state.rotate_weight)
		model.rotation = Vector3(0, rotation, 0)
#	if requested_move_direction:
#		var target_rotation = atan2(-requested_move_direction.x, -requested_move_direction.z)
#		var rotation = lerp_angle(model.rotation.y, target_rotation, .5)
#		model.rotation = Vector3(0, rotation, 0)

func control_rotation_chosen_direction(delta: float) -> void:
	var top_down_direction = chosen_rotation_direction
	if top_down_direction:
		top_down_direction = top_down_direction.normalized()
		var target_rotation = atan2(-top_down_direction.x, -top_down_direction.y)
		var rotation = lerp_angle(model.rotation.y, target_rotation, state_machine.state.rotate_weight)
		model.rotation = Vector3(0, rotation, 0)

func jump_and_gravity(delta: float) -> void:
	if(not was_grounded && grounded):
		prev_time_in_air = time_in_air
		time_in_air = 0
		time_grounded = 0
		
	if(was_grounded && not grounded):
		prev_time_grounded = time_grounded
		time_in_air = 0
	
	if(grounded):
		time_grounded += delta
		
		if(time_grounded > .14):
			road_runner_jump_available = true
			
	else:
		time_in_air += delta
				
		# Add the gravity.
		if(state_machine.state.gravity_enabled):
			if(velocity.y < 0):
				velocity.y -= GRAVITY * FALL_GRAVITY_MULTI * delta * customGravityMultiplier
			else:
				velocity.y -= GRAVITY * delta * customGravityMultiplier
				
var highJump = false;
func do_jump(skipBoostCheck = false):
	highJump = false;
	var jump_multiplier = 1.0
	if(!skipBoostCheck and time_grounded < .2 and prev_time_in_air > .5):
		jump_multiplier = 1.6
		highJump = true;
	velocity.y = sqrt(JUMP_HEIGHT * jump_multiplier * state_machine.state.jump_multiplier * 2 * GRAVITY)
	road_runner_jump_available = false


func raycast_forward(vertical_offset: float, ray_length: float) -> Dictionary:
	var space = get_world_3d().direct_space_state
	var directions = [last_non_zero_horizontal_velocity.normalized(), last_non_zero_requested_move_direction.normalized()]
	var results = [0, 0]
	for n in 2:
		var origin = position + Vector3(0, vertical_offset, 0)
		var end = position + Vector3(directions[n].x, vertical_offset, directions[n].z)
		var query = PhysicsRayQueryParameters3D.create(origin, end, 0b0011, [self])
		query.collide_with_areas = false
		query.hit_back_faces = false		
		results[n] = space.intersect_ray(query)
	
	if(not results[0]):
		return results[1]
	return results[0]

func isWall(cast: Dictionary) -> Dictionary:
	if(cast and not(cast.normal.y < .3 and cast.normal.y > -.3)):
		return {};
	return cast;

func check_wall_interactions() -> Array:
	var ray_length = 1.5
	var bot = raycast_forward(0, ray_length)
	var mid = raycast_forward(1, ray_length)
	var top = raycast_forward(2, ray_length)

	bot = isWall(bot)
	mid = isWall(mid)
	top = isWall(top)

	return [bot, mid, top]

func request_wall_interactions() -> Array:
	var wall_check = check_wall_interactions()
	var bot = wall_check[0]
	var mid = wall_check[1]
	var top = wall_check[2]
	
	var normal_to_use : Vector3
	
	var amount = 0
	if(bot):
		amount += 1
		normal_to_use = bot.normal
		
	if(top):
		amount += 1
		normal_to_use = top.normal		
		
	if(mid):
		amount += 1
		normal_to_use = mid.normal
		
	#can climb, can vault, can jump
	var results = [[false, null], [false, null], [false, null]];
	
	if input_buffer.is_action_just_pressed(Enums.INPUT.Interact):
		if top:
			results[0] = [true, top.normal.normalized()];
	
	if input_buffer.is_action_just_pressed(Enums.INPUT.Interact):
		if !top and ((mid and bot) or (!mid and bot) or (mid and !bot)):
			results[1] = [true, Vector3(normal_to_use.x, 0, normal_to_use.z).normalized()];
	
	if input_buffer.is_action_just_pressed(Enums.INPUT.Jump):
		if(amount >= 2) and is_on_wall_only():
			results[2] = [true, Vector3(normal_to_use.x, 0, normal_to_use.z).normalized()];
	
	return results;

var debug = [Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)];
func raycast_climb(climbingDirection: Vector3, wallNormal: Vector3) -> Array:
	var results = [0, 0, 0, 0]
	var space = get_world_3d().direct_space_state
	var radius = 1.0;
	var centerOfPlayer = position + Vector3(0, 1, 0);
	var origin1 = centerOfPlayer + (climbingDirection * radius);
	results[2] = origin1;
	var end1 = centerOfPlayer + (climbingDirection * -radius) + (wallNormal * -1);
	var query = PhysicsRayQueryParameters3D.create(origin1, end1, 0b0011, [self])
	query.collide_with_areas = false
	query.hit_back_faces = false
	debug[0] = query.from;
	debug[1] = query.to;
	results[0] = space.intersect_ray(query)
	query.from = centerOfPlayer + (climbingDirection * radius * .5);
	query.to = centerOfPlayer + (climbingDirection * radius * 1.7) + (wallNormal * -1);
	#results[3] = query.from;
	debug[2] = query.from;
	debug[3] = query.to;
	results[1] = space.intersect_ray(query)
	
	for n in 2:
		results[n] = isWall(results[n]);
	
	return results;

var detectedVictims = [];


func _on_attack_detector_body_entered(body):
	detectedVictims.push_back(body);
	pass # Replace with function body.


func _on_attack_detector_body_exited(body):
	detectedVictims.erase(body);
	pass # Replace with function body.
