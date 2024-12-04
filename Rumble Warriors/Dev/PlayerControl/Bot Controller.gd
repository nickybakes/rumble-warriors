extends Node


@onready var player : PlayerController = $"..";

var input_buffer : InputBufferBot;

var rng = RandomNumberGenerator.new()
var timeTilNewPath = 5.0;
var path = [];
var currentStepInPath = 0;

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
		var goalPoint = GameManager.inst.playerStatuses[0].playerController.global_position;
		path = NavManager.inst.shortestPathFull(player.global_position, goalPoint);
		_resetPathTimer();
	
	moveToGoal();
	
	
func moveToGoal():
	if(currentStepInPath < path.size() - 1):
		var currentPoint = path[currentStepInPath];
		var nextPoint = path[currentStepInPath + 1];
		input_buffer.move_to(player.global_position, nextPoint.position);
		
		var distToPoint = player.global_position.distance_to(path[currentStepInPath].position);
		if(distToPoint < 1.0):
			currentStepInPath += 1;
	else:
		#reached goal
		input_buffer.reset_move_direction();
	#input_buffer.move_to(player.global_position, )


func _resetPathTimer():
	timeTilNewPath = rng.randf_range(9, 12);
