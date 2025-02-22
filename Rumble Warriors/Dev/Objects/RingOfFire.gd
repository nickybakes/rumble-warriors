@tool
extends Node3D

var currentPosition : Vector3 = Vector3(0, 0, 0);
var currentRadius : float = 1;

@export_category("Commands")
@export var CreateEmberParticles: bool:
	set(value):
		create_ember_particles();


# Called when the node enters the scene tree for the first time.
func _ready():
	pass;
	#if not Engine.is_editor_hint():
		#scale = Vector3(10, 10, 10);
		#position = Vector3(0, 0, 0);		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scale.y = 1.0;
	scale.z = scale.x;
	if(position != currentPosition):
		currentPosition = position;
		RenderingServer.global_shader_parameter_set("ringCenter", Vector2(currentPosition.x, currentPosition.z));
	if(scale.x != currentRadius):
		currentRadius = scale.x;
		RenderingServer.global_shader_parameter_set("ringRadius", scale.x);

func delete_ember_particles():
	const startingIndex = 1;
	
	for index in range(startingIndex, get_child_count()):
		var child = get_child(startingIndex);
		remove_child(child);
		child.queue_free();

func create_ember_particles():
	delete_ember_particles();
	
	const numParticles = 16;
	
	var emberScene = load("res://Art/Particles/P_Ember_01.tscn") as PackedScene;
	
	for i in numParticles:
		var instance = emberScene.instantiate() as Node3D;
		var currentAngle = (i as float/numParticles as float) * (PI*2.0);
		get_tree().edited_scene_root.add_child(instance, true);
		instance.owner = get_tree().edited_scene_root;
		instance.position = Vector3(cos(currentAngle), 0, sin(currentAngle));
		instance.rotation = Vector3(0, -currentAngle, 0);
	
