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
	ClimbFromGround,
	Attack,
	ElbowDrop,
	ElbowDropRecovery,
	Victim,
	
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
	BasicStrike_01,
	ElbowDrop_01,
	ElbowDropLand_01,
	ElbowDropGetUp_01,
}

enum ATTACK
{
	BasicStrike_01,
	None,
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

enum SPEED_MODE
{
	Multiplied,
	Custom
}

enum PRIORITY
{
	Unblockable,
	Strike,
	Power,
	Super
}

enum INTERACTION
{
	Attack,
	Block,
	DodgeRoll,
	Pickup	
}

enum RESULT
{
	AttackSuccess,
	AttackClashed,
	AttackBlocked,
	AttackDodged
}
