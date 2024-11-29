extends Panel
class_name PlayerListDisplay

@onready var nameLabel = $Name;
@onready var avatar = $Avatar;
@onready var colorDisplay = $ColorDisplay as TextureRect;
@onready var hostCrown = $HostCrown as TextureRect;

func setupDisplay(playerDescription : Dictionary):
	nameLabel.text = playerDescription.displayName;
	Network.insertSteamAvatar(playerDescription.id, avatar);
	colorDisplay.modulate = playerDescription.color;
	hostCrown.visible = playerDescription.id == 1;

func setName(name : String):
	nameLabel.text = name;
	
func setAvatar(icon : ImageTexture):
	avatar.texture = icon;
	
func setColor(color : Color):
	colorDisplay.modulate = color;
