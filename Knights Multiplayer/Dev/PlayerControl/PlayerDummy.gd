extends Node3D
class_name PlayerDummy


@onready var model = $Model
@onready var header : PlayerHeader = $Header

var positionNetworked : Vector3
var rotationY : float


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = lerp(position, positionNetworked, .5);
	var rotation = lerp_angle(model.rotation.y, rotationY, .5);
	model.rotation = Vector3(0, rotation, 0);
	
