# Run.gd
extends PlayerState

var direction : Vector3

func _init():
	jump_multiplier = 1.5
	speed_multiplier = 1.0
	rotate_weight = 0.8
	
func enter(previousState : Enums.STATE, _msg := {}):
	player.animator.setAnimation(Enums.ANIMATION.Vault);
	direction = _msg["direction"]
	player.requested_move_direction = -direction
	player.velocity = -direction * player.current_speed()
	player.do_jump(true)
	pass

func update(delta: float) -> void:
	
	if(player.velocity.y < 0):
		if(!player.grounded):
			state_machine.transition_to(Enums.STATE.JumpFall)
			return

		if(player.grounded):
			state_machine.transition_to(Enums.STATE.Run)
			return
