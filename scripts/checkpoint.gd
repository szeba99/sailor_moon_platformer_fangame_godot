extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		
		Global.checkpoint_x = body.global_position.x
		Global.checkpoint_y = body.global_position.y
		
		Global.save_game()
		if body.has_method("victory_pose"):
			body.victory_pose()
		queue_free()
		
