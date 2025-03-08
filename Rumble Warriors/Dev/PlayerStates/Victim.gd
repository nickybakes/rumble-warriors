extends PlayerState

func _init():
	speed_mode = Enums.SPEED_MODE.Custom;

# Upon entering the state, we set the Player node's velocity to zero.
func enter(previousState: Enums.STATE, _msg := {}) -> void:
	pass;

func exit() -> void:
	player.requested_move_direction = Vector3.ZERO;
	player.velocity = Vector3.ZERO;
	pass;
	
func update(delta: float) -> void:
	player.combat_controller.updateAttack(delta);
