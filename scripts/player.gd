extends CharacterBody2D

@onready var animatedSprite = $AnimatedSprite2D

const SPEED = 300

const wall_speed = 70.0
const JUMP_VELOCITY = -350.0
const WALL_SLIDING_SPEED = 1200

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var doWallJump = false

func _physics_process(delta):
	var direction = Input.get_axis("Left", "Right")
	
	if is_on_wall_only() && (
		Input.is_action_pressed("Left") || Input.is_action_pressed("Right")): 
			velocity.y = WALL_SLIDING_SPEED * delta
	elif not is_on_floor(): velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("Jump"):
		if is_on_wall_only():
			velocity.y = JUMP_VELOCITY
			velocity.x = -direction * wall_speed
			doWallJump = true
			$WallJumpTimer.start()
		elif is_on_floor():
			velocity.y = JUMP_VELOCITY
	
	if direction && not doWallJump: velocity.x = direction * SPEED
	elif not doWallJump: velocity.x = move_toward(velocity.x, 0, SPEED)	
	
	#_setAnimation(direction)

	move_and_slide()
	
#func _setAnimation(direction):
	#if velocity.x > 0: animatedSprite.flip_h = false
	#elif velocity.x < 0: animatedSprite.flip_h = true
	#elif velocity.x == 0: 
		#if direction > 0: animatedSprite.flip_h = false
		#elif direction < 0: animatedSprite.flip_h = true	
		
	
	if is_on_wall_only() && (velocity.x != 0 || direction != 0):
		animatedSprite.flip_h = !animatedSprite.flip_h

	if !is_on_floor(): animatedSprite.play("jump")
	elif direction != 0: animatedSprite.play("run")
	else: animatedSprite.play("idle")

func _on_wall_jump_timer_timeout():
	doWallJump = false
