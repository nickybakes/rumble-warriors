class_name Enums
enum STATE
{
	Idle,
	Run,
	Skid,
	JumpFall,
	SideFlip,
	Walljump,
	Vault,
	Climb,
	ClimbFromGround
}

enum ANIMATION
{
	IdleRunBlend,
	Skid,
	Jump,
	HighJump,
	Fall,
	SideFlip,
	Walljump,
	Vault,
	Climb,
	ClimbSlide,
	ClimbJump,
}

enum ANIM_SM
{
	Platforming,
	Climbing,
	Combat,
	Knocked	
}

enum INPUT
{
	Jump,
	Strike,
	Grab,
	Interact,
	Dodge,
	Block,
	Lasso
}

enum ROTATION_MODE
{
	Velocity,
	Chosen_Direction,
	None
}

enum MOVEMENT_MODE
{
	Velocity,
	None
}

enum PRIORITY
{
	Unblockable,
	Strike,
	Power,
	Super
}
