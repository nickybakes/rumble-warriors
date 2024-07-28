extends MultiplayerSpawner

enum NetworkType{
	ENET,
	STEAM
}

#Network will set up callbacks and handle game networking such as 
#creating lobbies, joining lobbies, disconnects, etc.

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 10567

# Max number of players.
const MAX_PEERS = 12

var isHost : bool = false;

var networkType := NetworkType.ENET;

var peer : MultiplayerPeer = null

# Names for remote players in id:name format.
var players := {}

var lobby_id := -1

var purposefulDisconnect := false;

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal disconnect()
signal game_ended()
signal game_error(what : String)
signal game_log(what : String)


func _ready():
	# Keep connections defined locally, if they aren't likely to be used
	# anywhere else, such as with a lambda function for readability.

	multiplayer.peer_connected.connect(
		func(id : int):
			# Tell the connected peer that we have also joined
			#print(Global.instanceId + ": " + str(id));
			rpc_id(id, "player_join", Global.displayName);
	)
	multiplayer.peer_disconnected.connect(
		func(id : int):
			# Unregister this player. This doesn't need to be called when the
			# server quits, because the whole player list is cleared anyway!
			unregister_player(id)
	)
	multiplayer.connected_to_server.connect(
		func():
			print("connect " + Global.instanceId + ": " + str(peer.get_unique_id()));
			rpc("player_join", Global.displayName);
			connection_succeeded.emit()	
	)
	multiplayer.connection_failed.connect(
		func():
			multiplayer.multiplayer_peer = null
			connection_failed.emit()
	)
	multiplayer.server_disconnected.connect(
		func():
			end_connection();
	)
	
	Steam.lobby_joined.connect(
		func (new_lobby_id: int, _permissions: int, _locked: bool, response: int):
		if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
			lobby_id = new_lobby_id
			var id = Steam.getLobbyOwner(new_lobby_id)
			if id != Steam.getSteamID():
				connect_steam_socket(id)
				#rpc("player_join", Global.displayName);
		else:
			# Get the failure reason
			var FAIL_REASON: String
			match response:
				Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST:
					FAIL_REASON = "This lobby no longer exists."
				Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED:
					FAIL_REASON = "You don't have permission to join this lobby."
				Steam.CHAT_ROOM_ENTER_RESPONSE_FULL:
					FAIL_REASON = "The lobby is now full."
				Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR:
					FAIL_REASON = "Uh... something unexpected happened!"
				Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED:
					FAIL_REASON = "You are banned from this lobby."
				Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED:
					FAIL_REASON = "You cannot join due to having a limited account."
				Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED:
					FAIL_REASON = "This lobby is locked or disabled."
				Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN:
					FAIL_REASON = "This lobby is community locked."
				Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU:
					FAIL_REASON = "A user in the lobby has blocked you from joining."
				Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER:
					FAIL_REASON = "A user you have blocked is in the lobby."
			game_log.emit(FAIL_REASON)
	)
	Steam.lobby_created.connect(
		func(status: int, new_lobby_id: int):
			if status == 1:
				#lobby_id = new_lobby_id
				Steam.setLobbyData(new_lobby_id, "name", 
					str(Global.displayName, "'s Rumble"))
				create_steam_socket()
			else:
				game_error.emit("Error on create lobby!")
	)



# Lobby management functions.
@rpc("call_local", "any_peer")
func player_join(new_player_name : String):
	var id = multiplayer.get_remote_sender_id()
	players[id] = createPlayerObject(id, new_player_name);
	player_list_changed.emit()


func unregister_player(id):
	players.erase(id)
	player_list_changed.emit()
	
func createPlayerObject(id : int, name : String) -> Dictionary:
	#player object is:
	#id
	#displayName
	#readyStatus
	return {"id": id, "displayName": name, "ready": false};

#region Lobbies

func host_lobby(netType : NetworkType):
	match(netType):
		NetworkType.ENET:
			create_enet_host()
		NetworkType.STEAM:
			Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, MAX_PEERS)

func join_lobby(new_lobby_id : int):
	Steam.joinLobby(new_lobby_id)

#endregion

#region Steam Peer Management
func create_steam_socket():
	peer = SteamMultiplayerPeer.new()
	peer.create_host(0, [])
	multiplayer.set_multiplayer_peer(peer)
	rpc("player_join", Global.displayName);

func connect_steam_socket(steam_id : int):
	peer = SteamMultiplayerPeer.new()
	peer.create_client(steam_id, 0, [])
	multiplayer.set_multiplayer_peer(peer)

#endregion

#region ENet Peer Management
func create_enet_host():
	networkType = NetworkType.ENET;
	peer = ENetMultiplayerPeer.new()
	(peer as ENetMultiplayerPeer).create_server(DEFAULT_PORT)
	multiplayer.set_multiplayer_peer(peer)
	rpc("player_join", Global.displayName);

func create_enet_client(address : String):
	networkType = NetworkType.ENET;
	peer = ENetMultiplayerPeer.new()
	(peer as ENetMultiplayerPeer).create_client(address, DEFAULT_PORT)
	multiplayer.set_multiplayer_peer(peer)
	await multiplayer.connected_to_server

func leave_lobby():
	purposefulDisconnect = true;
	peer.close();
	Steam.leaveLobby(lobby_id);
	pass

#endregion

func spawn_gamemanager():
	var gameManager = load(get_spawnable_scene(0)).instantiate()
	add_child(gameManager)

@rpc("call_local")
func load_world():
	# Change scene.
	var world = load("res://Scenes/SCENE_Map_01.tscn").instantiate()
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node("Lobby").hide()
	
	get_tree().set_pause(false) # Unpause and unleash the game!

func begin_game():
	assert(multiplayer.is_server())
	spawn_gamemanager();

func begin_game2():
	#Ensure that this is only running on the server; if it isn't, we need
	#to check our code.
	assert(multiplayer.is_server())
	
	#call load_world on all clients
	load_world.rpc()
	
	#grab the world node and player scene
	var world : Node3D = get_tree().get_root().get_node("Map")
	var player_scene := load("res://Dev/PlayerControl/Player Status.tscn")
	
	#Iterate over our connected peer ids
	var spawn_index = 0
	
	for peer_id in players:
		var player : PlayerStatus = player_scene.instantiate()
		
		player.set_name("P " + str(peer_id))
		# "true" forces a readable name, which is important, as we can't have sibling nodes
		# with the same name.
		world.get_node("Players").add_child(player, true)
		
		#Set the authorization for the player. This has to be called on all peers to stay in sync.
		player.set_authority.rpc(peer_id)
		
		##Grab our location for the player.
		##var target : Vector2 = world.get_node("SpawnPoints").get_child(spawn_index).position
		#var target : Vector3 = Vector3(-6, 0, 0)
		##The peer has authority over the player's position, so to sync it properly,
		##we need to set that position from that peer with an RPC.
		#player.teleport.rpc_id(peer_id, target)
		
		spawn_index += 1
	
# create_steam_socket and connect_steam_socket both create the multiplayer peer, instead
# of _ready, for the sake of compatibility with other networking services
# such as WebSocket, WebRTC, or Steam or Epic.



#region Utility

func _make_string_unique(query : String) -> String:
	var count := 2
	var trial := query
	if Network.players.values().has(trial):
		trial = query + ' ' + str(count)
		count += 1
	return trial

@rpc("call_local", "any_peer")
func get_player_name() -> String:
	return players[multiplayer.get_remote_sender_id()].displayName

func is_game_in_progress() -> bool:
	return has_node("/root/Map")

func end_connection():
	#clear player and lobby data
	players.clear();
	lobby_id = -1;
	
	#delete spawned gamemanager and any leftovers from the network connection
	for n in get_children():
		remove_child(n)
		n.queue_free()
	
	#if the player wanted to disconnect, then we dont give em a error message
	#if it was NOT a purposeful disconnect, then give em an error message
	if(!purposefulDisconnect):
		game_error.emit("Server disconnected")
	#reset the "purposeful disconnect" status for the next possible disconnect
	purposefulDisconnect = false;
	player_list_changed.emit();
	disconnect.emit();

#endregion
