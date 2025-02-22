@tool
extends Node

var clock : float = 0.0;
var currentClock : float = 0.0;


# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.is_editor_hint():
		clock = 0.0;
		currentClock = 0.0;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	clock += delta;
	currentClock += delta;
	if(clock > .15):
		if(currentClock >= 100.0):
			currentClock = 0.0;
			if not Engine.is_editor_hint():
				get_tree().quit();
		RenderingServer.global_shader_parameter_set("steppedTime", currentClock + clock);
		clock = 0.0;
