extends Node


@onready var player : PlayerController = $"..";

var input_buffer : InputBufferBot;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_buffer = player.input_buffer;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(player.grounded):
		input_buffer.press_and_release_input(Enums.INPUT.Jump);
	pass
