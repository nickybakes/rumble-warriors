extends MultiplayerSpawner
class_name GameManager;


var spawnedLevelAndPlayers := false;

var botDescriptions = {};

var playerStatuses : Dictionary;
# This dict of playerStatus should be the same just not including the local client
var playerStatusesNotLocal : Dictionary;
var botStatuses : Dictionary;

const numBots = 0;

static var inst : GameManager;

@onready var combatManager = preload("res://Dev/Managers/Combat Manager.tscn");

# Called when the node enters the scene tree for the first time.
func _ready():
	inst = self;
	playerStatuses = {};
	botStatuses = {};
	get_tree().get_root().get_node("Lobby").hide()
	var cm = combatManager.instantiate();
	add_child(cm, true);
	print(Global.instanceId + " Game Manager Spawned with auth:" + str(is_multiplayer_authority()))

func addPlayerToList(player : PlayerStatus, id : int, isLocal : bool) -> void:
	playerStatuses[id] = player;
	if(!isLocal):
		playerStatusesNotLocal[id] = player;
	
func addBotToList(bot : PlayerStatus, botId : int) -> void:
	botStatuses[botId] = bot;

func spawn_players():
	var playerPrefab = load(get_spawnable_scene(1));
	var numPlayers = 0;
	for p in Network.playerDescriptions.values():
		var player : PlayerStatus = playerPrefab.instantiate()
		add_child(player, true);
		player.set_authority.rpc(p.id, -1, p);
		numPlayers += 1;
		
	for i in numBots:
		var description = {
			"displayName": "BOT" + str(i + 1),
			"customization": 
				{"color" : Network.PLAYER_COLORS_DEFAULT[(i + numPlayers) % Network.PLAYER_COLORS_DEFAULT.size()]}
			};
		var bot : PlayerStatus = playerPrefab.instantiate()
		add_child(bot, true);
		bot.set_authority.rpc(1, i, description);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!spawnedLevelAndPlayers):
		spawnedLevelAndPlayers = true;
		if(multiplayer.is_server()):
			var level = load(get_spawnable_scene(0)).instantiate()
			add_child(level)
			spawn_players();
	pass
