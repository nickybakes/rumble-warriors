@tool
extends GPUParticles3D

const WORLD_COLLISION_MASK = 0b0011;

var prevHeight : float = 0.0;
var newHeight : float = 0.0;
var clock : float = 0.0;
const clockMax : float = 0.4;


# Called when the node enters the scene tree for the first time.
func _ready():
	prevHeight = 0.0;
	newHeight = 0.0;
	clock = 0.0;
	getNewHeight();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	clock += delta;
	global_position.y = lerp(prevHeight, newHeight, clock/clockMax);
	#print(get_parent_node_3d().scale.x);
	if(clock >= clockMax):
		getNewHeight();
		clock = 0.0;

func getNewHeight():
	var space = get_world_3d().direct_space_state;
	var query = PhysicsRayQueryParameters3D.create(Vector3(global_position.x, 999999, global_position.z), Vector3(global_position.x, -999999, global_position.z), WORLD_COLLISION_MASK)
	query.collide_with_areas = false;
	query.hit_back_faces = false;
	query.hit_from_inside = false;
	var result = space.intersect_ray(query)
	if(result):
		prevHeight = newHeight;
		#global_position.y = newHeight;
		newHeight = result.position.y;
