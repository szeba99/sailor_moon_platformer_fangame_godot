extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var r = randf_range(0.0,0.25)
	$AnimatedSprite2D.self_modulate = Color(1-r,1,1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player_die"):
		body.player_die()
		#queue_free()
