extends Control

@export var player_name : Label
@export var error_label : Label
@export var host : Button
@export var lobby_container : Container

@export var inside_lobby_panel : Panel
@export var outside_lobby_panel : Panel
@export var windowInstanceLabel : Label

@onready var colorIcon = load("res://Art/Sprites/SPR_ColorIcon_01.png");

signal game_log(what : String)

func _ready():
	windowInstanceLabel.text = Global.instanceId;
	player_name.text = Global.displayName;
	
	# Called every time the node is added to the scene.
	Network.connection_failed.connect(self._on_connection_failed)
	Network.connection_succeeded.connect(self._on_connection_success)
	Network.player_list_changed.connect(self.refresh_lobby)
	Network.disconnect.connect(self._on_disconnect)
	Network.game_error.connect(self._on_game_error)
	Network.game_log.connect(self._on_game_log)
	Network.avatar_loaded.connect(self.refresh_lobby)
	
	game_log.connect(self._on_game_log)
	
	_setup_ui()

func _setup_ui():
	#Should be customizable, ultimately
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	
	Steam.lobby_match_list.connect(
		func(lobbies : Array):
			for sample in lobbies:
				var lobby_name : String = Steam.getLobbyData(sample, "name")
				var member_count : int = Steam.getNumLobbyMembers(sample)
				
				var join_button := Button.new()
				join_button.set_text(str(lobby_name, ": ", 
					member_count, " joined"))
				join_button.set_size(Vector2(100, 5))
				
				lobby_container.add_child(join_button)
				join_button.pressed.connect(
					func():
						outside_lobby_panel.hide()
						inside_lobby_panel.show()
						Network.join_lobby(
							sample)
				)
	)
	
	_request_lobby_list()

func _request_lobby_list():
	#Clear out lobby list
	for child in lobby_container.get_children():
		child.queue_free()
	
	Steam.requestLobbyList()

func _on_host_pressed():
	outside_lobby_panel.hide()
	inside_lobby_panel.show()
	Network.host_lobby(Network.NetworkType.STEAM)
	refresh_lobby()

func _on_connection_success():
	outside_lobby_panel.hide()
	inside_lobby_panel.show()


func _on_connection_failed():
	host.disabled = false
	error_label.set_text("Connection failed.")


func _on_disconnect():
	show()
	outside_lobby_panel.show()
	inside_lobby_panel.hide()
	host.disabled = false


func _on_game_error(errtxt : String):
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_centered()
	host.disabled = false

func _on_game_log(logtxt : String):
	print(logtxt)


func refresh_lobby():
	var playerIDs = Network.players
	var list = inside_lobby_panel.get_node("List") as ItemList;
	var colorList = inside_lobby_panel.get_node("ColorsList") as ItemList;
	list.clear();
	colorList.clear();
	for id in playerIDs:
		var displayName = Network.players[id].displayName;
		var listDisplayName = (displayName if 
				id != 1 else 
				(displayName + " (Host)"));
		var steamId = Network.players[id].steamId;
		if(Network.playerAvatars.keys().has(steamId)):
			var avatar = Network.playerAvatars[steamId];
			list.add_item(listDisplayName, avatar);
		else:
			Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, steamId);
			list.add_item(listDisplayName);
		colorList.add_icon_item(colorIcon, false);
		colorList.set_item_icon_modulate(colorList.item_count - 1, Color(1, 1, 1));
	
	inside_lobby_panel.get_node("Start").disabled = not multiplayer.is_server()
	#Ensure we have an actual lobby ID before continuing
	await Steam.lobby_joined
	inside_lobby_panel.get_node("LobbyID").text = str(Network.lobby_id)
	
	_request_lobby_list()
	
func changePlayerColor(color : Color) -> void:
	pass;
	
func _on_start_pressed():
	Network.begin_game()

func _on_enet_host_pressed():
	Network.host_lobby(Network.NetworkType.ENET);
	
	inside_lobby_panel.show();
	outside_lobby_panel.hide();

func _on_enet_join_pressed():
	Network.create_enet_client("127.0.0.1");


func _on_leave_lobby_pressed():
	Network.leave_lobby();
	
	inside_lobby_panel.hide();
	outside_lobby_panel.show();
