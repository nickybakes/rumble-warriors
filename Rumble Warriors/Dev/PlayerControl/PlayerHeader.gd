extends Panel
class_name PlayerHeader


@onready var label = $NameLabel;
@onready var avatar = $Avatar as TextureRect;

@onready var player : Node3D = get_parent();

var camera : Camera3D;

func setName(name : String):
	label.text = name;
	
func setAvatar(id : int):
	Network.insertSteamAvatar(id, avatar);

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_viewport().get_camera_3d();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(camera == null):
		camera = get_viewport().get_camera_3d();
	else:
		var playerPos = player.global_position + Vector3(0, 2.2, 0);
		if(!camera.is_position_behind(playerPos)):
			if(!visible):
				visible = true;
			position = camera.unproject_position(playerPos)
			var dot = camera.get_global_transform().basis.z.dot((playerPos - camera.global_position).normalized());
			modulate.a = clamp((-2.0*dot) - 1.0, 0.0, 1.0);
		elif visible:
			visible = false;
		#var scaleVal = clamp( camera.rotation.dot((dummyPos - camera.position).normalized()), 0.0, 1.0)
		#scale = Vector2(scaleVal, scaleVal)
		
	#This is such a stupid fix for a stupid issue.
	#The issue: on players after P1, the players dummys for the players after them dont have
	#a nametag on their character. Its because the size somehow is getting set to (NaN, NaN)
	#and the only fix is to have this in the _process function. It doesnt work if we have it
	#in _ready or in the setName, setAvatar, etc funcs. 
	if(is_nan(size.x)):
		set_size(Vector2.ONE);
	pass
