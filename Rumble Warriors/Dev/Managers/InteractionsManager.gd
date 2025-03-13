extends Node
class_name InteractionsManager

## All Attack resources to be loaded into the game.
@export var attacks : Array[R_Attack];

# This script is for managing networked combat interactions.

var interactions : Array[R_Attack];

static var inst : InteractionsManager;

# Called when the node enters the scene tree for the first time.
func _ready():
	inst = self;
	
func get_attack(attack : Enums.ATTACK) -> R_Attack:
	return attacks[attack];

func sendInteractionToHost(interaction : R_Interaction):
	GameManager.inst.rpc_id(1, "sendInteractionToHost", interaction);
	
func hostReceivesInteraction(interaction : R_Interaction):
	## Host should look through list of current ineractions and see if anything
	## blocks or clashes or needs a correction. 
	## Then the host should send the result to ALL clients (including the host).
	for recordedInteraction in interactions:
		
		pass;
		
	
	pass;



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#for n in hitSubmissions.size():
		#pass
	pass
