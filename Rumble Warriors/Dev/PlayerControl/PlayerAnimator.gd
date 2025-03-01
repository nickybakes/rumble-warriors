extends Node
class_name PlayerAnimator

@onready var tree = $SK_PlayerTest_01/AnimationTree as AnimationTree
@onready var animPlayer = $SK_PlayerTest_01/AnimationPlayer as AnimationPlayer
@onready var animSM = $SK_PlayerTest_01/AnimationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback;
@onready var attackAnimSM = $SK_PlayerTest_01/AnimationTree.get("parameters/Attack State Machine/playback") as AnimationNodeStateMachinePlayback;


@onready var playerModel = $SK_PlayerTest_01/rig/Skeleton3D/SK_PlayerTest_01 as MeshInstance3D;

var playerModelMaterial : ShaderMaterial;

var currentAnimation := Enums.ANIMATION.IdleRunBlend;
var previousAnimation := Enums.ANIMATION.IdleRunBlend;

var currentAttackAnimation := Enums.ATTACK_ANIMATION.BasicStrike_01;

var animationVar0 := 0.0;
var animationVar1 := 0.0;
var animationVar2 := 0.0;

var current2DBlend = Vector2.ZERO;

# Called when the node enters the scene tree for the first time.
func _ready():
	playerModelMaterial = playerModel.get_surface_override_material(0).next_pass;
	playerModelMaterial.get_instance_id();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#tree.set("parameters/Idle-Run-Blend/blend_position", 1.0);
	pass
	
func setPlayerCustomization(customization : Dictionary):
	playerModelMaterial.set_shader_parameter("playerColor", customization.color);


func setAnimation(animation : Enums.ANIMATION, dontResetBlends = false):
	if(animation == currentAnimation):
		return;
	currentAnimation = animation;
	animSM.start(Enums.ANIMATION.keys()[animation], true);
	match(currentAnimation):
		Enums.ANIMATION.IdleRunBlend:
			resetBlends(animation);
		Enums.ANIMATION.ClimbSlide:
			resetBlends(animation);
			current2DBlend = tree.get("parameters/ClimbSlide/blend_position");
		Enums.ANIMATION.Climb:
			if(!dontResetBlends):
				resetBlends(animation);
			current2DBlend = tree.get("parameters/Climb/blend_position");
		Enums.ANIMATION.ClimbJump:
			resetBlends(animation);
			current2DBlend = tree.get("parameters/ClimbJump/blend_position");

func setAttackAnimation(animation : Enums.ATTACK_ANIMATION):
	if(currentAnimation == Enums.ANIMATION.Attack && currentAttackAnimation == animation):
		return;
	currentAnimation = Enums.ANIMATION.Attack;
	currentAttackAnimation = animation;
	#animSM.stop();
	animSM.start("Attack State Machine");
	attackAnimSM.start(Enums.ATTACK_ANIMATION.keys()[animation], true);
	pass;

func setAnimationVar0(animVar : float, forceUpdate := false):
	if(animVar != animationVar0 or forceUpdate):
		match(currentAnimation):
			Enums.ANIMATION.IdleRunBlend:
				tree.set("parameters/IdleRunBlend/blend_position", animVar)
			Enums.ANIMATION.ClimbSlide:
				current2DBlend.x = animVar;
				tree.set("parameters/ClimbSlide/blend_position", current2DBlend)
			Enums.ANIMATION.Climb:
				current2DBlend.x = animVar;
				tree.set("parameters/Climb/blend_position", current2DBlend)
			Enums.ANIMATION.ClimbJump:
				current2DBlend.x = animVar;
				tree.set("parameters/ClimbJump/blend_position", current2DBlend)
		
		
		animationVar0 = animVar;
		
func setAnimationVar1(animVar : float, forceUpdate := false):
	if(animVar != animationVar1 or forceUpdate):
		match(currentAnimation):
			Enums.ANIMATION.ClimbSlide:
				current2DBlend.y = animVar;
				tree.set("parameters/ClimbSlide/blend_position", current2DBlend)
			Enums.ANIMATION.Climb:
				current2DBlend.y = animVar;
				tree.set("parameters/Climb/blend_position", current2DBlend)
			Enums.ANIMATION.ClimbJump:
				current2DBlend.y = animVar;
				tree.set("parameters/ClimbJump/blend_position", current2DBlend)
		animationVar1 = animVar;
		
		
func setAnimationVar2(animVar : float, forceUpdate := false):
	if(animVar != animationVar2 or forceUpdate):
		animationVar2 = animVar;


func resetBlends(animation : Enums.ANIMATION):
	match(animation):
		Enums.ANIMATION.IdleRunBlend:
			tree.set("parameters/IdleRunBlend/blend_position", 0)
		Enums.ANIMATION.ClimbSlide:
			tree.set("parameters/ClimbSlide/blend_position", Vector2.ZERO)
		Enums.ANIMATION.Climb:
			tree.set("parameters/Climb/blend_position", Vector2.ZERO)
		Enums.ANIMATION.ClimbJump:
			tree.set("parameters/ClimbJump/blend_position", Vector2.ZERO)
