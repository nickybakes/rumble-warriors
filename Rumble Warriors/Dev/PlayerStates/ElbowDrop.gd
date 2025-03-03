# Run.gd
extends PlayerState

var ySpeed = 0.0;

func _init():
	rotation_mode = Enums.ROTATION_MODE.None
	
func enter(previousState : Enums.STATE, _msg := {}):
	player.customGravityMultiplier = 2.0;
	ySpeed = 0.0;
	player.animator.setAnimation(Enums.ANIMATION.ElbowDrop_01);
	pass;
	
func exit():
	player.customGravityMultiplier = 1.0;

func update(delta: float) -> void:
	var player_input = player.get_requested_move_direction()
	
	var yVel = abs(player.velocity.y);
	if(yVel != 0.0):
		ySpeed = yVel;
	
	if(player.grounded):
		state_machine.transition_to(Enums.STATE.ElbowDropRecovery, {"ySpeed": ySpeed});
		return
		
	player.requested_move_direction = player_input
	
func physics_update(delta: float) -> void:
	pass
