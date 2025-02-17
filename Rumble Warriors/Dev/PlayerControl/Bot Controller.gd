extends Node


@onready var player : PlayerController = $"..";

var input_buffer : InputBufferBot;

var rng = RandomNumberGenerator.new()
var timeTilNewPath = 5.0;
var path = [];
var currentStepInPath = 0;
var goalPosition = Vector3.ZERO;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_buffer = player.input_buffer;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if(player.grounded):
		#input_buffer.press_and_release_input(Enums.INPUT.Jump);
	timeTilNewPath -= delta;
	if(timeTilNewPath <= 0):
		goalPosition = GameManager.inst.playerStatuses.get(1).playerController.global_position + Vector3(0, .5, 0);
		path = NavManager.inst.shortestPathFull(player.global_position, goalPosition);
		currentStepInPath = 0;
		_resetPathTimer();

	moveToGoal();
	
	
func moveToGoal():
	if(currentStepInPath < path.size() && path.size() > 0):
		var currentPosition = player.global_position;
		var currentPoint = currentPosition;
		var nextPoint = goalPosition;
		if(currentStepInPath == -1):
			nextPoint = path[0].position;
		elif currentStepInPath != path.size() - 1:
			currentPoint = path[currentStepInPath].position;
			nextPoint = path[currentStepInPath + 1].position;
			
		input_buffer.move_to(currentPosition, nextPoint);
		
		#var desiredVelocity = nextPoint - currentPoint;
		#var topDownDistance = Vector2(nextPoint.x - currentPoint.x, nextPoint.z - currentPoint.z).length_squared();
		#
		#if(desiredVelocity.y > 0.3 && topDownDistance < 7):
			#input_buffer.press_and_release_input(Enums.INPUT.Jump);
		
		var distToPoint = player.global_position.distance_squared_to(nextPoint);
		if(distToPoint < .5):
			currentStepInPath += 1;
	else:
		#reached goal
		input_buffer.reset_move_direction();
	#input_buffer.move_to(player.global_position, )


func _resetPathTimer():
	timeTilNewPath = rng.randf_range(5, 6.5);
