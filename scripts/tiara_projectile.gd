extends Area2D

var direction = Vector2.ZERO  # Ez az "üres" tartály, amibe Sailor Moon beleönti az irányt
@export var speed = 400.0     # Ezt az Inspectorban is állíthatod majd


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Ellenőrizzük, hogy amit eltaláltunk, az ellenség-e
	if body.has_method("enemy_die"): 
		body.enemy_die() # Meghívjuk az ellenség saját halál-függvényét
		queue_free() # A Tiara eltűnik a becsapódáskor

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
