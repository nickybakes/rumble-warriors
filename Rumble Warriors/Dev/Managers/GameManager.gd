extends MultiplayerSpawner
class_name GameManager;


var spawnedLevelAndPlayers := false;

var botDescriptions = {};

var playerStatuses;
var botStatuses;

const numBots = 5;

static var inst;

# Called when the node enters the scene tree for the first time.
func _ready():
	inst = self;
	get_tree().get_root().get_node("Lobby").hide()
	print(Global.instanceId + " Game Manager Spawned with auth:" + str(is_multiplayer_authority()))

func spawn_players():
	playerStatuses = [];
	botStatuses = [];
	
	var playerPrefab = load(get_spawnable_scene(1));
	var numPlayers = 0;
	for p in Network.playerDescriptions.values():
		var player : PlayerStatus = playerPrefab.instantiate()
		add_child(player, true);
		player.set_authority.rpc(p.id, false, p);
		numPlayers += 1;
		playerStatuses.push_back(player);
		
	for i in numBots:
		var description = {
			"displayName": "BOT" + str(i + 1),
			"customization": 
				{"color" : Network.PLAYER_COLORS_DEFAULT[(i + numPlayers) % Network.PLAYER_COLORS_DEFAULT.size()]}
			};
		var bot : PlayerStatus = playerPrefab.instantiate()
		add_child(bot, true);
		bot.set_authority.rpc(1, true, description);
		botStatuses.push_back(bot);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!spawnedLevelAndPlayers):
		spawnedLevelAndPlayers = true;
		if(multiplayer.is_server()):
			var level = load(get_spawnable_scene(0)).instantiate()
			add_child(level)
			spawn_players();
	pass
