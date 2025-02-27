extends Node

var arguments : Dictionary;

const numPlayers = 5;
const mainDelay = .1;
const playerJoinDelay = .3;


var player : int;

var timer := 0.0;

var inLobby = false;
var gameStarted = false;

@onready var lobbyManager = $".." as LobbyManager;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parse_cmd_arguments();
	player = int(arguments['player']);

func parse_cmd_arguments():
	arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.contains("="):
			var key_value = argument.split("=")
			arguments[key_value[0].trim_prefix("--")] = key_value[1]
		else:
			# Options without an argument will be present in the dictionary,
			# with the value set to an empty string.
			arguments[argument.trim_prefix("--")] = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta;
	if(player == 0 && timer >= mainDelay && !inLobby):
		lobbyManager._on_enet_host_pressed();
		inLobby = true;
		pass;
	elif(player == 0 && timer >= (playerJoinDelay * (numPlayers + 1)) + mainDelay && !gameStarted):
		lobbyManager._on_start_pressed();
		gameStarted = true;
		pass;
	elif(timer >= (playerJoinDelay * player) + mainDelay && !inLobby):
		lobbyManager._on_enet_join_pressed();
		inLobby = true;
	pass
