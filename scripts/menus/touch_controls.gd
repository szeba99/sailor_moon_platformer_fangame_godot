extends Button
@export var input : String

func _on_button_down() -> void:
	#
	Input.action_press(input) 

func _on_button_up() -> void:
	#
	Input.action_release(input)
