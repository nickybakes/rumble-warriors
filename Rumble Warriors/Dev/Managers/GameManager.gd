extends MultiplayerSpawner


var spawnedLevelAndPlayers := false;

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().get_node("Lobby").hide()
	print(Global.instanceId + " Game Manager Spawned with auth:" + str(is_multiplayer_authority()))


func spawn_players():
	var playerPrefab = load(get_spawnable_scene(1));
	var index = 0;
	for p in Network.playerDescriptions.values():
		var player : PlayerStatus = playerPrefab.instantiate()
		add_child(player, true);
		player.set_authority.rpc(p.id)
		index += 1;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!spawnedLevelAndPlayers):
		spawnedLevelAndPlayers = true;
		if(multiplayer.is_server()):
			var level = load(get_spawnable_scene(0)).instantiate()
			add_child(level)
			spawn_players();
	pass
