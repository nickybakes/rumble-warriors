extends Panel
class_name PlayerHUD


@onready var pingLabel = $PingLabel as Label;

#@onready var player : Node3D = get_parent();

var currentPing = 0;

func _init():
	#GameManager.inst.add_child(self, true);
	pass;

func setPing(ping : int):
	pingLabel.text = str(ping);
	currentPing = ping;
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Network.timeManager.latency != currentPing):
		setPing(Network.timeManager.latency);
