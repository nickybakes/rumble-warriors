extends Resource
class_name R_Attack

@export_category("Hit Field")
## This value should be the actual range, not the squared range.
@export var range := 3.0;
@export var angleThresholdHorizontal := .5;
@export var angleThresholdVertical := .5;
@export var heightOffset := 0.0;

@export_category("Timings")
@export var windupTime = .25;
@export var recoveryTime = .15;
## How long after recovery starts to allow for 
## input for the next attack in a combo.
@export var comboAvailableStartTime = .075;

@export_category("Animations")
@export var attackAnimation := Enums.ATTACK_ANIMATION.BasicStrike_01;
## Should go from 0 to 1. Will be scaled to the duration of windup.
@export var velocityAnimation : Animation;

@export_category("Properties")
@export var damage := 25.0;
@export var staminaDamage := 0.0;
@export var staminaCost := 0.0;
@export var nextAttackInCombo := Enums.ATTACK.BasicStrike_01;



var squaredRange = 0.0;

func _init() -> void:
	squaredRange = pow(range, 2);
