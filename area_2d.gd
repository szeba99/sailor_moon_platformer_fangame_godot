extends Area2D

# Ezzel jelezzük a játéknak, hogy kaptunk egy pontot
var collected = false
var coinsound = preload("res://sounds/coin1.mp3")

func _ready():
	# Elugrik egy véletlenszerű időpontra (0 és a hossza között) az animációban
	$AnimationPlayer.advance(randf_range(0, $AnimationPlayer.current_animation_length))

func _on_body_entered(body: Node2D) -> void:
	# Csak akkor fut le, ha a Player ér hozzá és még nem gyűjtöttük be
	if body.name == "Player" and not collected:
		collect()

func collect():
	collected = true
	# Megkeressük a SoundPlayert név alapján a pályán
	# (Feltételezve, hogy a World-ben van közvetlenül)
	var sfx_player = get_tree().root.find_child("SoundPlayer", true, false)
	
	if sfx_player:
		if sfx_player.stream != coinsound:
			sfx_player.stream = coinsound
		sfx_player.play_sfx() # Szólunk neki, hogy csörrenjen meg
	
	# PONTADÁS
	var label = get_tree().root.find_child("number", true, false)
	if label:
		label.add_coin()
	
	
	# érme elpusztítása
	$CollisionShape2D.set_deferred("disabled", true)
	# Elrejtjük a grafikát
	$Sprite2D.visible = false
	
	# Animáció és törlés (ahogy eddig is volt)
	#var tween = get_tree().create_tween()
	#tween.tween_property(self, "modulate:a", 0, 0.3)
	await $AudioStreamPlayer2D.finished
	queue_free()
