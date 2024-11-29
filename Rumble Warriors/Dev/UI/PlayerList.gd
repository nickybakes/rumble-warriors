extends VBoxContainer
class_name PlayerList

#multiplayer ID : index in children
var playerDisplays = {};

var playerListDisplayPrefab = preload("res://Dev/UI/PlayerListDisplay.tscn");

func addPlayer(playerDescription : Dictionary) -> void:
	var display = playerListDisplayPrefab.instantiate() as PlayerListDisplay;
	add_child(display);
	playerDisplays[playerDescription.id] = get_child_count() - 1;
	display.setupDisplay(playerDescription);
	pass;

func clear() -> void:
	for n in get_children():
		remove_child(n);
		n.queue_free();


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
