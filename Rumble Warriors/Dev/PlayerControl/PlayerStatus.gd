extends Node
class_name PlayerStatus

#PlayerStatus is a networked synchronized representation of a player
#It will store networked synced info about the player such as
#health, stamina, position, Y rotation, current state/animation
#when its multiplayer authority is set, it will create 1 of 2 things:
#if we have authority, create a Player Controller and grab info from that
#if NO authority, the ncreate a Player Dummy, which is purely just a representation
#of a player on a nother client. We will get data from the network and give it
#to the dummy so it can do interpolation on position, etc

@export var positionNetworked : Vector3
@export var rotationY : float

@export var health : float
@export var stamina : float

@export var animation := Enums.ANIMATION.IdleRunBlend;
@export var animationVar0 := 0.0;
@export var animationVar1 := 0.0;
@export var animationVar2 := 0.0;

var playerController : PlayerController;
var playerDummy : PlayerDummy;

var playerControllerScene := preload("res://Dev/PlayerControl/Player Controller.tscn");
var playerDummyScene := preload("res://Dev/PlayerControl/Player Dummy.tscn");

var id : int;

var authSet := false;

@rpc("any_peer", "call_local")
func set_authority(_id : int) -> void:
	id = _id;
	set_multiplayer_authority(id)
	print(Global.instanceId + " player status set auth: " + str(id) + str(is_multiplayer_authority()));
	if(is_multiplayer_authority()):
		var player : PlayerController = playerControllerScene.instantiate()
		playerController = player;
		add_child(player, true);
	else:
		var player : PlayerDummy = playerDummyScene.instantiate()
		playerDummy = player;
		add_child(player, true);
		player.header.setName(Network.players[id].displayName);
		
	authSet = true;
	
	
@rpc("any_peer", "call_local")
func teleport(new_position : Vector3) -> void:
	positionNetworked = new_position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if authSet:
		if(is_multiplayer_authority()):
			positionNetworked = playerController.position;
			rotationY = playerController.model.rotation.y;
			animation = playerController.animator.currentAnimation;
			animationVar0 = playerController.animator.animationVar0;
			animationVar1 = playerController.animator.animationVar1;
			animationVar2 = playerController.animator.animationVar2;
		else:
			playerDummy.positionNetworked = positionNetworked;
			playerDummy.rotationY = rotationY;
			playerDummy.animator.setAnimation(animation);
			playerDummy.animator.setAnimationVar0(animationVar0);
			playerDummy.animator.setAnimationVar1(animationVar1);
			playerDummy.animator.setAnimationVar2(animationVar2);
	pass
