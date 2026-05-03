extends Button

func _ready() -> void:
	if OS.has_feature("web"):
		visible = false

func _on_button_up() -> void:
	if not OS.has_feature("web"):
		get_tree().quit()
