extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_JUMPS = 2 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") 

var jumps_made = 0 

func _physics_process(delta):
	var sprite = $Sprite
	if not is_on_floor():
		velocity.y += gravity * delta
	var direction = Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if is_on_floor():
		jumps_made = 0
		
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor() or jumps_made < MAX_JUMPS:
			velocity.y = JUMP_VELOCITY
			jumps_made += 1 

	move_and_slide()

	
	if direction != 0:
		
		sprite.play("walk")
		
		sprite.flip_h = direction < 0 
	else:
		sprite.play("idle_kedip")


func _on_area_wayang_body_entered(body: Node2D) -> void:
	pass 
