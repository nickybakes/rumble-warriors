extends PlayerState

func _init():
	speed_multiplier = 1

# Upon entering the state, we set the Player node's velocity to zero.
func enter(previousState: Enums.STATE, _msg := {}) -> void:
	pass;

func exit() -> void:
	pass;
	
func update(delta: float) -> void:
	player.combat_controller.update(delta);
