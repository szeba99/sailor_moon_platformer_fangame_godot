extends Button

var menu_is_open : bool = false
@export var TouchControl : Control



func _on_toggled(toggled_on: bool) -> void:
	$MainMenu.visible = toggled_on
	$MainMenu/VBoxContainer/Continue.grab_focus()
	get_tree().paused = toggled_on
	menu_is_open = toggled_on
	if !toggled_on:
		$MainMenu/VBoxContainer/Options/OptionsMenu.visible = toggled_on
		$MainMenu/VBoxContainer/Options.options_open = toggled_on
	if TouchControl:
		TouchControl.visible = !toggled_on


func _on_continue_pressed() -> void:
	_on_toggled(false)
	button_pressed = false
	$MainMenu/VBoxContainer/Options/OptionsMenu.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if menu_is_open:
			if $MainMenu/VBoxContainer/Options.options_open:
				$MainMenu/VBoxContainer/Options/OptionsMenu.visible = false
				$MainMenu/VBoxContainer/Options.options_open = false
				$MainMenu/VBoxContainer/Options.button_pressed = false
				$MainMenu/VBoxContainer/Options.grab_focus()
			else:
				_on_toggled(false)
				button_pressed = false
		else:
			_on_toggled(true)
			button_pressed = true
