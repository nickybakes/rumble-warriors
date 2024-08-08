extends Node
class_name PlayerAnimator

@onready var tree = $SK_PlayerTest_01/AnimationTree as AnimationTree
@onready var animPlayer = $SK_PlayerTest_01/AnimationPlayer as AnimationPlayer
@onready var animSM = $SK_PlayerTest_01/AnimationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback;

var currentAnimation := Enums.ANIMATION.IdleRunBlend;
var previousAnimation := Enums.ANIMATION.IdleRunBlend;

var animationVar0 := 0.0;
var animationVar1 := 0.0;
var animationVar2 := 0.0;

var current2DBlend = Vector2.ZERO;

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#tree.set("parameters/Idle-Run-Blend/blend_position", 1.0);
	pass


func setAnimation(animation : Enums.ANIMATION):
	if(animation != currentAnimation):
		currentAnimation = animation;
		animSM.start(Enums.ANIMATION.keys()[animation], true);
		match(currentAnimation):
			Enums.ANIMATION.ClimbSlide:
				current2DBlend = tree.get("parameters/ClimbSlide/blend_position");
		
func setAnimationVar0(animVar : float):
	if(animVar != animationVar0):
		match(currentAnimation):
			Enums.ANIMATION.IdleRunBlend:
				tree.set("parameters/IdleRunBlend/blend_position", animVar)
			Enums.ANIMATION.ClimbSlide:
				current2DBlend.x = animVar;
				tree.set("parameters/ClimbSlide/blend_position", current2DBlend)
		animationVar0 = animVar;
		
func setAnimationVar1(animVar : float):
	if(animVar != animationVar1):
		match(currentAnimation):
			Enums.ANIMATION.ClimbSlide:
				current2DBlend.y = animVar;
				tree.set("parameters/ClimbSlide/blend_position", current2DBlend)
		animationVar1 = animVar;
		
		
func setAnimationVar2(animVar : float):
	if(animVar != animationVar2):
		animationVar2 = animVar;


func resetBlends(animation : Enums.ANIMATION):
	match(animation):
		Enums.ANIMATION.IdleRunBlend:
			tree.set("parameters/IdleRunBlend/blend_position", 0)
		Enums.ANIMATION.ClimbSlide:
			tree.set("parameters/ClimbSlide/blend_position", Vector2.ZERO)
