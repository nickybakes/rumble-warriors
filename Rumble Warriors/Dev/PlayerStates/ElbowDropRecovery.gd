# Run.gd
extends PlayerState

var extraStunTime = 0.0;

var gettingUp = false;

func _init():
	rotation_mode = Enums.ROTATION_MODE.None
	
func enter(previousState : Enums.STATE, _msg := {}):
	player.animator.setAnimation(Enums.ANIMATION.ElbowDropLand_01);
	player.requested_move_direction = Vector3.ZERO;
	var ySpeed = _msg["ySpeed"] as float;
	const min = 60.0;
	const max = 150.0;
	extraStunTime = (clamp(ySpeed, min, max) - min)/max;
	gettingUp = false;
	pass;
	
func exit():
	pass;
	
func update(delta: float) -> void:
	if(!gettingUp && state_machine.time_in_state >= .26 + extraStunTime):
		gettingUp = true;
		player.animator.setAnimation(Enums.ANIMATION.ElbowDropGetUp_01);
	elif(gettingUp && state_machine.time_in_state >= .78 + extraStunTime):
		state_machine.transition_to(Enums.STATE.Idle)
	
func physics_update(delta: float) -> void:
	pass
