extends Button


func _on_button_up() -> void:
	Global.reset_checkpoint()
	Global.save_game()
	Global.load_game(Global.save_name)
	get_tree().paused = false
	get_tree().reload_current_scene()
