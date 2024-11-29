extends Panel
class_name PlayerCustomizationPanel

@onready var colorPicker = $PlayerColorPicker as ColorPickerButton;
@onready var applyButton = $ApplyCustomizationButton as Button;

var playerColor : Color;

signal player_customization_changed();

func setColor(color : Color):
	colorPicker.color = color;
	applyButton.disabled = true;

func onChangeColor(color : Color):
	playerColor = color;
	applyButton.disabled = false;
	
func onApply():
	player_customization_changed.emit();
	
