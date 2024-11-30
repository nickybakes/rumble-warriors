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

const PLAYER_COLORS_DEFAULT = [Color("ff2828"), Color("113dff"), Color("fff609"), Color("00bc25"), Color("fa6000"), Color("650e9e"), Color("ff00b3"), Color("02d6dd")];

var isHost : bool = false;

var networkType := NetworkType.ENET;

var peer : MultiplayerPeer = null

# Names for remote players in id:player format.

#player id: bool (true if fully connected, data sent. false is still connecting BUT connection registered)
var playerConnections := {}
#player id : player description (name, customization, steam id, etc);
var playerDescriptions := {}
#steam id : ImageTexture
var playerAvatars := {}

#steamId : textureRect
var textureRectsWaitingForAvatars := {}

var myDescription := {};

var myCustomization := {"color": PLAYER_COLORS_DEFAULT[0]};

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
signal avatar_loaded()
signal avatar_insert_ready(textureRect : TextureRect)
signal player_customization_changed()

func _ready():
	# Keep connections defined locally, if they aren't likely to be used
	# anywhere else, such as with a lambda function for readability.

	multiplayer.peer_connected.connect(
		func(id : int):
			pass;
			# Tell the connected peer that we have also joined
			#print(Global.instanceId + ": PEER CONNECTED " + str(id));
			#rpc_id(id, "player_join", Global.displayName, Global.steam_id, myCustomization);
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
			rpc_id(1, "register_player_connection");
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
	Steam.avatar_loaded.connect(_on_loaded_avatar)

func getSteamAvatar(multiplayerId : int) -> ImageTexture:
	if(playerAvatars.keys().has(Network.playerDescriptions[multiplayerId].steamId)):
		return playerAvatars[Network.playerDescriptions[multiplayerId].steamId];
	return Global.PLACEHOLDER_AVATAR;
	
func insertSteamAvatar(multiplayerId : int, textureRect : TextureRect):
	var steamId = playerDescriptions[multiplayerId].steamId;
	if(playerAvatars.has(steamId)):
		textureRect.texture = playerAvatars[steamId];
	else:
		if(textureRectsWaitingForAvatars.has(steamId)):
			textureRectsWaitingForAvatars[steamId].push_back(textureRect);
		else:
			textureRectsWaitingForAvatars[steamId] = [textureRect];
		textureRect.texture = Global.PLACEHOLDER_AVATAR;
		Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, steamId);
		
@rpc("call_local", "any_peer")
func update_player_customization(playerCustomization : Dictionary):
	var id = multiplayer.get_remote_sender_id();
	myDescription.customization = playerCustomization;
	rpc_id(1, "update_player_description", myDescription);
	

# Lobby management functions.
@rpc("call_local", "any_peer")
func register_player_connection():
	var id = multiplayer.get_remote_sender_id()
	playerConnections[id] = false;
	rpc_id(id, "accept_player_connection", {"playerCount" : playerConnections.size()});
	
@rpc("call_local", "authority")
func accept_player_connection(data : Dictionary):
	var id = multiplayer.get_remote_sender_id()
	setupMyCustomization(data.playerCount);
	myDescription = createPlayerObject(multiplayer.get_unique_id(), Global.displayName, Global.steam_id, myCustomization);
	rpc_id(1, "update_player_description", myDescription);
	
@rpc("call_local", "any_peer")
func update_player_description(description : Dictionary):
	var id = multiplayer.get_remote_sender_id()
	playerConnections[id] = true;
	playerDescriptions[id] = description;
	rpc("update_all_player_descriptions", playerDescriptions);
	
@rpc("call_local", "authority")
func update_all_player_descriptions(playerDescs : Dictionary):
	playerDescriptions = playerDescs;
	player_list_changed.emit();

func unregister_player(id):
	if(multiplayer.is_server()):
		playerConnections.erase(id)
		playerDescriptions.erase(id)
		rpc("update_all_player_descriptions", playerDescriptions);
	
func createPlayerObject(id : int, name : String, steam_id : int, customization : Dictionary) -> Dictionary:
	#player object is:
	#id
	#displayName
	#readyStatus
	#steamId
	#customization (cosmetic choices basically)
		#color
	return {"id": id, "displayName": name, "ready": false, "steamId": steam_id, "customization": customization};

func setupMyCustomization(playerCount : int):
	myCustomization.color = PLAYER_COLORS_DEFAULT[(playerCount - 1) % PLAYER_COLORS_DEFAULT.size()];

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
	rpc_id(1, "register_player_connection");

func connect_steam_socket(steam_id : int):
	peer = SteamMultiplayerPeer.new()
	peer.create_client(steam_id, 0, [])
	multiplayer.set_multiplayer_peer(peer)
	
func _on_loaded_avatar(user_id: int, avatar_size: int, avatar_buffer: PackedByteArray) -> void:
	# Create the image and texture for loading
	var avatar_image: Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)

	# Optionally resize the image if it is too large
	if avatar_size > 128:
		avatar_image.resize(128, 128, Image.INTERPOLATE_LANCZOS)

	# Apply the image to a texture
	var avatar_texture: ImageTexture = ImageTexture.create_from_image(avatar_image)
	
	playerAvatars[user_id] = avatar_texture;
	if(textureRectsWaitingForAvatars.has(user_id)):
		for textureRect in textureRectsWaitingForAvatars[user_id]:
			if(textureRect != null):
				textureRect.texture = avatar_texture;
		textureRectsWaitingForAvatars.erase(user_id);
	avatar_loaded.emit();

#endregion

#region ENet Peer Management
func create_enet_host():
	networkType = NetworkType.ENET;
	peer = ENetMultiplayerPeer.new()
	(peer as ENetMultiplayerPeer).create_server(DEFAULT_PORT)
	multiplayer.set_multiplayer_peer(peer)
	rpc_id(1, "register_player_connection");

func create_enet_client(address : String):
	networkType = NetworkType.ENET;
	peer = ENetMultiplayerPeer.new()
	(peer as ENetMultiplayerPeer).create_client(address, DEFAULT_PORT)
	multiplayer.set_multiplayer_peer(peer)
	await multiplayer.connected_to_server

func leave_lobby():
	purposefulDisconnect = true;
	if(peer):
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

## create_steam_socket and connect_steam_socket both create the multiplayer peer, instead
## of _ready, for the sake of compatibility with other networking services
## such as WebSocket, WebRTC, or Steam or Epic.

#region Utility

func _make_string_unique(query : String) -> String:
	var count := 2
	var trial := query
	if Network.playerDescriptions.values().has(trial):
		trial = query + ' ' + str(count)
		count += 1
	return trial

@rpc("call_local", "any_peer")
func get_player_name() -> String:
	return playerDescriptions[multiplayer.get_remote_sender_id()].displayName

func is_game_in_progress() -> bool:
	return has_node("/root/Map")

func end_connection():
	#clear player and lobby data
	for id in playerDescriptions.keys():
		textureRectsWaitingForAvatars.erase(playerDescriptions[id].steamId);
	playerDescriptions.clear();
	playerConnections.clear();
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
