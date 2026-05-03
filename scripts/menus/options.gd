extends Button

@export var options_menu : ColorRect
@onready var options_open : bool = $OptionsMenu.visible;

func _on_toggled(toggled_on: bool) -> void:
	if options_menu:
		options_menu.visible = toggled_on
		options_open = toggled_on
		if toggled_on:
			$OptionsMenu/Fullscreen_Label/Fullscreen_Switch.grab_focus()
		else:
			grab_focus()
