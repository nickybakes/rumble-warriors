# Run.gd
extends PlayerState

var startPos;
var endPos;

func _init():
	rotation_mode = Enums.ROTATION_MODE.None
	
func enter(previousState : Enums.STATE, _msg := {}):
	player.animator.setAnimationVar0(0);
	if(player.velocity.y >= 0):
		if(player.highJump):
			player.animator.setAnimation(Enums.ANIMATION.HighJump);
		else:
			player.animator.setAnimation(Enums.ANIMATION.Jump);
	else:
		player.animator.setAnimation(Enums.ANIMATION.Fall);
	speed_multiplier = 1;
	startPos = player.position;

func update(delta: float) -> void:
	
	if(player.velocity.y < 0):
		player.animator.setAnimation(Enums.ANIMATION.Fall);
	
	var player_input = player.get_requested_move_direction()
	
	if(player.time_in_air > .35 && player.combat_controller.checkInputs(delta)):
		return
	
	if(player.grounded and player_input):
		state_machine.transition_to(Enums.STATE.Run)
		return
		
	if(player.grounded and not player_input):
		state_machine.transition_to(Enums.STATE.Idle)
		return
		
	player.requested_move_direction = player_input
	
func physics_update(delta: float) -> void:
	var wall_interact = player.request_wall_interactions()
	if wall_interact[0][0] and player.time_in_air > .2:
		state_machine.transition_to(Enums.STATE.Climb, {"wallNormal": wall_interact[0][1]});
		return
	
	if wall_interact[1][0] and player.time_in_air > .2:
		state_machine.transition_to(Enums.STATE.Vault, {"direction": wall_interact[1][1]})
		return
			
	if wall_interact[2][0] and player.time_in_air > .25:
		state_machine.transition_to(Enums.STATE.Walljump, {"direction": wall_interact[2][1]})
		return
	
	if player.input_buffer.is_action_just_pressed(Enums.INPUT.Jump):
		if (player.road_runner_jump_available && player.time_in_air < player.ROAD_RUNNER_TIME_MAX):
			player.do_jump()
	pass
