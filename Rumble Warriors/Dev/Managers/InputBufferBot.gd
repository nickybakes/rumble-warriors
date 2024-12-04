extends InputBuffer
class_name InputBufferBot

var move_direction = Vector2.ZERO;

func move_to(current : Vector3, goal : Vector3):
	move_direction = Vector2(Vector2(goal.x, goal.z) - Vector2(current.x, current.z)).normalized();
	
func reset_move_direction():
	move_direction = Vector2.ZERO;
	
func get_movement_direction() -> Vector2:
	return move_direction;
		
func press_input(input : Enums.INPUT):
	_input_just_pressed(input);
	
func release_input(input : Enums.INPUT):
	_input_just_released(input);
	
func press_and_release_input(input : Enums.INPUT):
	_input_just_pressed(input);
	_input_just_released(input);
