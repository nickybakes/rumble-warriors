extends Node

#Global will log into Steam, load settings, and handle overall app state


@onready var PLACEHOLDER_AVATAR = preload("res://icon.svg") as Texture2D;


# Steam variables
var is_on_steam_deck: bool = false
var is_online: bool = false
var is_owned: bool = false
var steam_app_id: int = 480
var steam_id: int = 0
var displayName: String = "Player"

var instanceId : String;



func _init() -> void:
	# Set your game's Steam app ID here
	OS.set_environment("SteamAppId", str(steam_app_id))
	OS.set_environment("SteamGameId", str(steam_app_id))
	instanceId = str(OS.get_process_id());


func _ready() -> void:
	initialize_steam()


func _process(_delta: float) -> void:
	Steam.run_callbacks()


func initialize_steam() -> void:
	var initialize_response: Dictionary = Steam.steamInitEx()
	#print("Did Steam initialize?: %s" % initialize_response)

	if initialize_response['status'] > 0:
		print("Failed to initialize Steam. Shutting down. %s" % initialize_response)
		get_tree().quit()

	# Gather additional data
	is_on_steam_deck = Steam.isSteamRunningOnSteamDeck()
	is_online = Steam.loggedOn()
	is_owned = Steam.isSubscribed()
	steam_id = Steam.getSteamID()
	displayName = Steam.getPersonaName() + " " + instanceId;

	# Check if account owns the game
	if is_owned == false:
		print("User does not own this game")
		get_tree().quit()
		
	print("Steam initialized. Welcome " + displayName);
