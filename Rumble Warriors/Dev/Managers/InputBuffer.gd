class_name InputBuffer

const MAX_INPUT_BUFFER_TIME := .2

var inputs_pressed := []
var inputs_released := []
var inputs_held_time := []
var inputs_is_held := []
var inputs := ["jump", "strike", "grab", "interact", "dodge", "block", "holster"]

func _init() -> void:
	for i in inputs.size():
		inputs_pressed.push_back(1.0);
		inputs_released.push_back(1.0);
		inputs_held_time.push_back(0.0);
		inputs_is_held.push_back(false);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta):
	for n in inputs.size():
		inputs_pressed[n] += delta
		inputs_released[n] += delta
		if(inputs_is_held[n]):
			inputs_held_time[n] += delta

func _input_just_pressed(inputIndex : int):
	inputs_pressed[inputIndex] = 0.0
	inputs_held_time[inputIndex] = 0.0
	inputs_is_held[inputIndex] = true;
	
func _input_just_released(inputIndex : int):
	inputs_held_time[inputIndex] = 0.0
	inputs_released[inputIndex] = 0.0
	inputs_is_held[inputIndex] = false;
	
func get_movement_direction() -> Vector2:
	return Vector2.ZERO;
			
func is_action_just_pressed(input : Enums.INPUT) -> bool:
	return inputs_pressed[input] < MAX_INPUT_BUFFER_TIME
	
func is_action_just_released(input : Enums.INPUT) -> bool:
	return inputs_released[input] < MAX_INPUT_BUFFER_TIME
	
func is_action_pressed(input : Enums.INPUT) -> bool:
	return inputs_is_held[input]
	
func action_held_time(input : Enums.INPUT) -> float:
	return inputs_held_time[input]
	
