extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	print(Global.instanceId + " Game Manager Spawned with auth:" + str(is_multiplayer_authority()))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
