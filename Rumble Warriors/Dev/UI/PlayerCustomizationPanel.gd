extends Panel
class_name PlayerCustomizationPanel

@onready var colorPicker = $PlayerColorPicker as ColorPickerButton;
@onready var applyButton = $ApplyCustomizationButton as Button;

var playerColor : Color;

signal player_customization_applied();


func _ready() -> void:
	updateCustomizationToCurrent();
	Network.connection_accepted.connect(self.updateCustomizationToCurrent);
	Network.player_customization_updated.connect(self.updateCustomizationToCurrent);
	pass;

#forces the customization display to show the current colors we have
func updateCustomizationToCurrent():
	setColor(Network.myCustomization.color);
	applyButton.disabled = true;
	pass;

func setColor(color : Color):
	colorPicker.color = color;

func _on_color_changed(color: Color) -> void:
	playerColor = color;
	applyButton.disabled = false;
	
func onApply():
	Network.myCustomization.color = playerColor;
	Network.update_player_customization();
	player_customization_applied.emit();
	
