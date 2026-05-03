extends CharacterBody2D
@export var follow_horizontal: bool = true
@export var follow_vertical: bool = true

@export var godmode : bool = false
var is_dead : bool = false
var input_reactivated = false #this is the time window after death until we cannot press a button to respawn
var is_busy : bool = false

var rng = RandomNumberGenerator.new()

@export var friction: float = 50.0  # Kezdésnek az 50 egy jó érték

var coyote_timer: float = 0.0
const COYOTE_TIME: float = 0.15 # Ez kb. 9 képkocka, pont elég a "csaláshoz"


const SPEED = 400.0
const JUMP_VELOCITY = -1000.0

# Változók az eredeti méretek tárolására
var original_height: float
var original_position_y: float


var is_shooting : bool = false
@export var projectile = preload("res://prefabs/inner_logic/moon_tiara_projectile.tscn")
var projectile_instance : Area2D

func _ready() -> void:
	# Játék elején elmentjük, mekkorára rajzoltad az ütközőt az editorban
	original_height = $CollisionShape2D.shape.height
	original_position_y = $CollisionShape2D.position.y
	
	
	Global.load_game(Global.save_name)
	
	#load checkpoint if one is set (0.0 means it isn't set)
	if Global.checkpoint_x != 0.0:
		load_checkpoint()


func _physics_process(delta: float) -> void:
	
	# Kamera követés vezérlése
	if has_node("Camera2D"):
		var cam = $Camera2D
		# Ha nem akarjuk, hogy kövessen egy irányba, "leválasztjuk" a globális pozícióját
		if not follow_horizontal:
			cam.top_level = true # Kiszakad a Player hierarchiájából vizuálisan
			cam.global_position.x = 0 # Vagy egy fix érték a szobád közepén
		if not follow_vertical:
			cam.top_level = true
			cam.global_position.y = 0
			
			
	
	
	# 0. Meghalva ne csússz oldalra (vagy ha elfoglalt vagy)
	if is_dead or is_busy:
		velocity.x = 0
		if Input.is_anything_pressed() and input_reactivated:
			player_death()
	
	
	# 1. Gravitáció kezelése
	if not is_on_floor():
		var current_gravity = get_gravity()
		
		# Ha lefelé esik a karakter (velocity.y > 0), szorozzuk meg a gravitációt
		if velocity.y > 0:
			velocity += current_gravity * 1.5 * delta # 2.0x-es húzóerő lefelé
		else:
			velocity += current_gravity * delta
	
	



	# 3. Irány lekérése (Ez minden képkockánál lefut, nem csak ugráskor!)
	var direction := Input.get_axis("ui_left", "ui_right")
	var is_crouching := Input.is_action_pressed("ui_down") and is_on_floor()
	
	#A lövés teljes kódja
	#épp lő-e
	
	
	
	if Input.is_action_just_pressed("left_action") and not is_shooting and projectile_instance == null:
		if is_dead : return #meghalva mégis mi az istent akarsz csinálni
		if is_busy : return # nem érsz most rá erre
		is_shooting = true
		$AnimatedSprite2D.play("attack")
		$AudioStreamPlayer2D.stream = load("res://sounds/moon/MoonTiaraShot.mp3")
		$AudioStreamPlayer2D.volume_linear = 0.9
		$AudioStreamPlayer2D.pitch_scale = rng.randf_range(0.8,1.0)
		$AudioStreamPlayer2D.play()
		
		#birth of a new projectile
		#var projectile_instance = projectile.instantiate()
		projectile_instance = projectile.instantiate()
		get_parent().add_child(projectile_instance)
		
		#positioning the new projectile
		projectile_instance.global_position = global_position
		projectile_instance.global_position.y -= 100
		
		if $AnimatedSprite2D.flip_h == true:
			projectile_instance.direction = Vector2.LEFT
		else:
			projectile_instance.direction = Vector2.RIGHT
		
		
		
		
		
	if is_shooting:
		velocity.x = velocity.x*0.95
	
# Coyote Time kezelése
	if is_on_floor():
		coyote_timer = COYOTE_TIME # Ha a földön vagyunk, alaphelyzetbe állítjuk
	else:
		coyote_timer -= delta # Ha a levegőben, elkezd ketyegni visszafelé

####################################################x
#######################################################
###########################################################


	if !is_shooting and !is_dead and !is_busy:
		
		# 2. Ugrás kezelése (MÓDOSÍTVA)
		# Az is_on_floor() helyett a coyote_timer-t nézzük!
		if Input.is_action_just_pressed("ui_accept") and coyote_timer > 0.0 and not is_crouching:
			velocity.y = JUMP_VELOCITY
			$AudioStreamPlayer2D.stream = load("res://sounds/moon/jump.mp3")
			$AudioStreamPlayer2D.volume_linear = 0.2
			$AudioStreamPlayer2D.pitch_scale = rng.randf_range(0.8,1.0)
			$AudioStreamPlayer2D.play()
			coyote_timer = 0.0 # Ugrás után azonnal nullázzuk, hogy ne tudjon duplán ugrani a levegőben

		# Változó ugrási magasság:
		# Ha elengeded a gombot ("just_released") ÉS még felfelé tartasz:
		if Input.is_action_just_released("ui_accept") and velocity.y < 0:
			velocity.y *= 0.1 # Felére csökkentjük a lendületet (ezt az értéket állíthatod)

		if is_crouching:
			velocity.x = velocity.x/1.1 # Guggolás közben ne csússzon el (vagy oszd el a SPEED-et)
			# Dinamikusan a fele:
			$CollisionShape2D.shape.height = original_height * 0.5
			# Matematikailag kiszámoljuk az eltolást, hogy az alja fix maradjon:
			$CollisionShape2D.position.y = original_position_y + (original_height * 0.25)
			
			
			# Animáció: lejátszás, de megáll az utolsó képkockán
			$AnimatedSprite2D.play("crouch")
			if $AnimatedSprite2D.frame == $AnimatedSprite2D.sprite_frames.get_frame_count("crouch") - 1:
				$AnimatedSprite2D.pause()
		else:
			# Visszaállítjuk az elmentett eredeti értékeket
			$CollisionShape2D.shape.height = original_height
			$CollisionShape2D.position.y = original_position_y
			
			# Normál mozgás és animációk
			if not is_on_floor():
				$AnimatedSprite2D.play("jump")
			elif direction != 0:
				$AnimatedSprite2D.play("run")
				$AnimatedSprite2D.flip_h = (direction < 0)
			else:
				$AnimatedSprite2D.play("idle")

				
			

			if direction:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, friction)

	move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	is_shooting = false

#hazards and enemies can call this function
func player_die():
	if godmode: return
	if is_busy: return
	$DeathTimer.start()
	$DeathTimer/InputReactivator.start()
	$AnimatedSprite2D.play("death")
	$AudioStreamPlayer2D.stream = load("res://sounds/moon/DSYELL.wav")
	$AudioStreamPlayer2D.play()
	is_dead = true

	


func _on_death_timer_timeout() -> void:
	player_death()

#final part of the death function
func player_death():
	Global.lives -= 1
	Global.save_game()
	get_tree().reload_current_scene()


func _on_input_reactivator_timeout() -> void:
	input_reactivated = true

func victory_pose():
	
	$AnimatedSprite2D.play("victory")
	is_busy = true
	
	#wait for animation to finish
	if $AnimatedSprite2D.is_playing() and $AnimatedSprite2D.animation == "victory":
		await $AnimatedSprite2D.animation_finished
	
	is_busy = false

func victory_pose2():
	
	$AnimatedSprite2D.play("victory2")
	is_busy = true
	
	#wait for animation to finish
	if $AnimatedSprite2D.is_playing() and $AnimatedSprite2D.animation == "victory2":
		await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("idle_2")
	#is_busy = false


func load_checkpoint():
	global_position.x = Global.checkpoint_x
	global_position.y = Global.checkpoint_y
