extends CharacterBody2D

@export var speed: float = 50.0
@export var turn_at_ledge: bool = true 

var direction: int = -1 # -1 = balra, 1 = jobbra
var is_attacking: bool = false
var can_kill: bool = false # Ez vezérli, hogy a türelmi idő letelt-e

@export var reaction_time: float = 0.2

@onready var sprite = $AnimatedSprite2D
@onready var ray = $RayCast2D
@onready var detection_area = $Area2D # Győződj meg róla, hogy ez a neve a fában!

var is_dead = false

@onready var sfx_player = get_tree().root.find_child("SoundPlayer", true, false)
var attack_sound = preload("res://sounds/enemy_touch.mp3")

func enemy_die():
	if is_dead: return # Ha már halott, ne csináljon semmit
	
	is_dead = true
	# Itt állítsd meg a mozgást (ha van velocity-je)
	velocity = Vector2.ZERO 
	
	$AnimatedSprite2D.play("death")
	# Opcionális: Kapcsold ki az ütközését, hogy ne akadjon bele Sailor Moon
	$CollisionShape2D.set_deferred("disabled", true)
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "death":
		queue_free() # Kitörli a Shade-et a játékból





func _physics_process(delta):
	if not is_dead:
		
		# 1. Gravitáció
		if not is_on_floor():
			velocity.y += get_gravity().y * delta
		
		# 2. Mozgás és Támadás kezelése
		if is_attacking:
			velocity.x = 0 # Megáll, amíg hadonászik
			
			# Ha már letelt a 0.3 mp türelmi idő, folyamatosan nézzük a halált
			if can_kill:
				check_kill_condition()
		else:
			# Normál séta
			velocity.x = direction * speed
			sprite.play("walk")
			
			# Fordulás falnál - OKOSABB verzió
		if is_on_wall():
			# Megnézzük a fal ütközési irányát (normálvektorát)
			var wall_normal = get_wall_normal()
			
			# Ha balra megyünk (-1) és a fal tőlünk balra van (normal.x > 0), 
			# VAGY ha jobbra megyünk (1) és a fal tőlünk jobbra van (normal.x < 0):
			if (direction == -1 and wall_normal.x > 0) or (direction == 1 and wall_normal.x < 0):
				flip_shade()
			
		# Fordulás szakadéknál
		if turn_at_ledge and is_on_floor() and not ray.is_colliding():
			flip_shade()
		
		move_and_slide()

func check_kill_condition():
	# Megnézzük, hogy Sailor Moon benne van-e az Area2D-ben
	var bodies = detection_area.get_overlapping_bodies()
	for b in bodies:
		if b.has_method("player_die"):
			b.player_die()

func flip_shade():
	direction *= -1
	sprite.flip_h = (direction == 1)
	# A RayCast átugrik a szörny másik oldalára
	ray.position.x = abs(ray.position.x) * direction
	ray.force_raycast_update()

# --- JELZÉS (SIGNAL) ---
# Ezt az Area2D -> Node -> body_entered(body) szignálhoz kell kötni!
func _on_area_2d_body_entered(body):
	if body.name == "Player" and not is_attacking and not is_dead:
		start_attack()

func start_attack():
	is_attacking = true
	can_kill = false # A támadás legelején még nem halálos (türelmi idő)
	sprite.play("attack")
	sfx_player.stream = attack_sound
	sfx_player.play()
	
	# 1. REAKCIÓIDŐ: Várunk 0.2 másodpercet
	await get_tree().create_timer(reaction_time).timeout
	
	# 2. HALÁLOS FÁZIS: Mostantól a _physics_process-ben a check_kill_condition() ölhet
	can_kill = true
	
	# Megvárjuk, amíg az animáció teljesen véget ér
	if sprite.is_playing() and sprite.animation == "attack":
		await sprite.animation_finished
	
	# 3. LEZÁRÁS: Visszaállítunk mindent alaphelyzetbe
	is_attacking = false
	can_kill = false
