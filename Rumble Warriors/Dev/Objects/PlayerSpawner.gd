extends MultiplayerSpawner


@export var playerScene : PackedScene

var players = {};

## Called when the node enters the scene tree for the first time.
#func _ready():
	#spawn_function = spawnPlayer
	#if(is_multiplayer_authority()):
		#spawn(1);
		#multiplayer.peer_connected.connect(spawn);
		#multiplayer.peer_disconnected.connect(removePlayer);
#
#
#func spawnPlayer(data) -> Node:
	#var p = playerScene.instantiate()
	#p.set_multiplayer_authority(data);
	#p.position = Vector3(-6, 0, 0);
	#players[data] = p;
	#return p;
#
#
#func removePlayer(data):
	#players[data].queue_free();
	#players.erase(data);
