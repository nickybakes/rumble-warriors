extends Panel
class_name PlayerHeader


@onready var label = $Label;
@onready var avatar = $Avatar;

@onready var playerDummy : PlayerDummy = get_parent();

var camera : Camera3D;

func setName(name : String):
	label.text = name;
	
func setAvatar(icon : ImageTexture):
	avatar.texture = icon;

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_viewport().get_camera_3d();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(camera == null):
		camera = get_viewport().get_camera_3d();
	else:
		var dummyPos = playerDummy.global_position + Vector3(0, 2.2, 0);
		position = Vector2(400, 400);
		position = camera.unproject_position(dummyPos)
		var dot = camera.get_global_transform().basis.z.dot((dummyPos - camera.global_position).normalized());
		modulate.a = clamp((-2.0*dot) - 1.0, 0.0, 1.0);
		#var scaleVal = clamp( camera.rotation.dot((dummyPos - camera.position).normalized()), 0.0, 1.0)
		#scale = Vector2(scaleVal, scaleVal)
	pass
