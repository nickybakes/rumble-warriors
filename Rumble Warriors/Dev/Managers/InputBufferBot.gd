extends InputBuffer
class_name InputBufferBot
		
func press_input(input : Enums.INPUT):
	_input_just_pressed(input);
	
func release_input(input : Enums.INPUT):
	_input_just_released(input);
	
func press_and_release_input(input : Enums.INPUT):
	_input_just_pressed(input);
	_input_just_released(input);
