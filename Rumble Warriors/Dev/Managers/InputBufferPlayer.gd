extends InputBuffer
class_name InputBufferPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta):
	super.update(delta);
	for n in inputs.size():
		if(Input.is_action_just_pressed(inputs[n])):
			_input_just_pressed(n);
		if(Input.is_action_just_released(inputs[n])):
			_input_just_released(n);


func get_movement_direction() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
