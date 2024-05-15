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

@export var position : Vector3
@export var rotationY : float

@export var health : float
@export var stamina : float

var playerController : PlayerController;
var playerDummy : PlayerDummy;

@rpc("any_peer", "call_local")
func set_authority(id : int) -> void:
	set_multiplayer_authority(id)
	
@rpc("any_peer", "call_local")
func teleport(new_position : Vector3) -> void:
	position = new_position

# Called when the node enters the scene tree for the first time.
func _ready():
	print(is_multiplayer_authority());


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
