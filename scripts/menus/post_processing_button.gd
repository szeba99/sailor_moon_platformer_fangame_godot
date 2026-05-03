extends Button

@export var post_processing : WorldEnvironment

func _on_toggled(toggled_on: bool) -> void:
	if post_processing:
		post_processing.environment.glow_enabled = toggled_on
		text = str(toggled_on)
