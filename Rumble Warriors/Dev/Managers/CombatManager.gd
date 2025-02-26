extends Node
class_name CombatManager

## All Attack resources to be loaded into the game.
@export var attacks := [] as Array[R_Attack];

# This script is for managing networked combat interactions.


var hitSubmissions = [];


static var inst : CombatManager;

# Called when the node enters the scene tree for the first time.
func _ready():
	inst = self;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for n in hitSubmissions.size():
		pass
	pass
