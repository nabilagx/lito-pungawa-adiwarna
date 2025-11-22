extends CharacterBody2D

# Konstanta Pergerakan
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_JUMPS = 2 # Jumlah lompatan maksimum (1 di darat, 1 di udara)

# Konstanta Fisika
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") 

# Variabel Status
var jumps_made = 0 # Melacak berapa kali lompatan sudah dilakukan

func _physics_process(delta):
	# Dapatkan referensi ke Node Sprite (AnimatedSprite2D)
	var sprite = $Sprite
	
	# 1. GRAVITASI
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. INPUT DAN PERGERAKAN HORIZONTAL
	var direction = Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	# 3. LOGIKA DOUBLE JUMP
	if is_on_floor():
		# Reset penghitung lompatan saat Lito menyentuh lantai
		jumps_made = 0
		
	if Input.is_action_just_pressed("ui_accept"):
		# Lito bisa lompat jika dia di lantai ATAU masih punya sisa lompatan
		if is_on_floor() or jumps_made < MAX_JUMPS:
			velocity.y = JUMP_VELOCITY
			jumps_made += 1 # Tambah penghitung lompatan

	# 4. PINDAHKAN KARAKTER
	move_and_slide()

	# 5. ATUR ANIMASI DAN FLIP SPRITE
	if direction != 0:
		# Sedang bergerak (Jalan)
		sprite.play("walk")
		# Membalik sprite: true jika direction < 0 (ke kiri), false jika > 0 (ke kanan)
		sprite.flip_h = direction < 0 
	else:
		# Diam (Idle)
		sprite.play("idle_kedip")
