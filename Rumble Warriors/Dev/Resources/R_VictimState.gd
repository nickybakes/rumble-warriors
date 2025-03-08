extends Resource
class_name R_VictimState

@export_category("Hit Field")
## This value should be the actual range, not the squared range.
@export var range := 3.0;
@export var angleThresholdHorizontal := .5;
@export var angleThresholdVertical := .5;
@export var heightOffset := 0.0;

@export_category("Timings")
@export var windupTime = .25;
@export var recoveryTime = .8;
## How long after recovery starts to allow for 
## input for the next attack in a combo.
@export var comboAvailableStartTime = .25;

@export_category("Animations")
@export var victimAnimation := Enums.ANIMATION.BasicStrike_01;
## Sets the velocity, relative to the direction of the player,
## during the attack.
@export var velocityTimeline : R_VelocityTimeline;

@export_category("Properties")
@export var damage := 25.0;
@export var staminaDamage := 0.0;
@export var staminaCost := 0.0;
@export var nextAttackInCombo := Enums.ATTACK.None;



var squaredRange = 0.0;

func _init() -> void:
	squaredRange = pow(range, 2.0);
	
func total_time() -> float:
	return windupTime + recoveryTime;
	
func combo_start_total_time() -> float:
	return windupTime + comboAvailableStartTime;
	
func sample_velocity(time : float) -> Vector3:
	if(velocityTimeline != null):
		return velocityTimeline.sample(time / total_time());
	else:
		return Vector3.ZERO;
