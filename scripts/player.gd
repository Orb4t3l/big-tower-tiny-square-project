extends CharacterBody2D

# ==== Constants ====
const GRAVITY := 1200.0
const SPEED := 250.0
const JUMP_VELOCITY := 400.0
const WALL_JUMP_PUSH_FORCE := 300.0
const WALL_SLIDE_SPEED := 80.0

const JUMP_BUFFER_TIME := 0.15
const COYOTE_TIME := 0.1
const WALL_JUMP_LOCK_DURATION := 0.15
const WALL_JUMP_COOLDOWN := 0.2

# ==== Nodes ====
@onready var sprite: Sprite2D = $Sprite2D
@onready var left_wall_check := $left_wall_check
@onready var right_wall_check := $right_wall_check

@onready var wall_jump_particles := $wall_jump_particles
@onready var jump_dust_particles := $jump_dust_particles
@onready var run_dust_left := $run_dust_left
@onready var run_dust_right := $run_dust_right

@onready var jump_sfx := $jump_sfx
@onready var wall_jump_sfx := $wall_jump_sfx
@onready var land_sfx := $land_sfx

# ==== State ====
var jump_buffer_time := 0.0
var coyote_time := 0.0
var wall_jump_lock_timer := 0.0
var wall_jump_cooldown_timer := 0.0
var was_on_floor := false
var wall_sliding := false

func _physics_process(delta):
	var input_direction = Input.get_action_strength("Right") - Input.get_action_strength("Left")

	# === Update timers ===
	if not is_on_floor():
		coyote_time = max(coyote_time - delta, 0.0)
	else:
		coyote_time = COYOTE_TIME

	jump_buffer_time = max(jump_buffer_time - delta, 0.0)
	wall_jump_lock_timer = max(wall_jump_lock_timer - delta, 0.0)
	wall_jump_cooldown_timer = max(wall_jump_cooldown_timer - delta, 0.0)

	# === Apply gravity ===
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# === Movement ===
	if wall_jump_lock_timer <= 0.0:
		velocity.x = input_direction * SPEED

	# === Flip sprite ===
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

	# === Jump input buffer ===
	if Input.is_action_just_pressed("Jump"):
		jump_buffer_time = JUMP_BUFFER_TIME

	# === Wall detection ===
	var wall_dir = 0
	if left_wall_check.is_colliding():
		wall_dir = -1
	elif right_wall_check.is_colliding():
		wall_dir = 1

	# === Wall sliding ===
	wall_sliding = false
	if wall_dir != 0 and not is_on_floor() and velocity.y > 0 and wall_jump_lock_timer <= 0.0:
		var moving_into_wall = (wall_dir == -1 and Input.is_action_pressed("Left")) or (wall_dir == 1 and Input.is_action_pressed("Right"))
		if moving_into_wall:
			wall_sliding = true
			velocity.y = min(velocity.y, WALL_SLIDE_SPEED)

	# === Wall jump ===
	if wall_dir != 0 and jump_buffer_time > 0.0 and not is_on_floor() and wall_jump_cooldown_timer <= 0.0:
		velocity.y = -JUMP_VELOCITY
		velocity.x = wall_dir * -WALL_JUMP_PUSH_FORCE
		wall_jump_lock_timer = WALL_JUMP_LOCK_DURATION
		wall_jump_cooldown_timer = WALL_JUMP_COOLDOWN
		jump_buffer_time = 0.0

		if wall_dir == -1:
			wall_jump_particles.rotation_degrees = 180
		else:
			wall_jump_particles.rotation_degrees = 0
		wall_jump_particles.restart()
		wall_jump_particles.emitting = true
		wall_jump_sfx.play()

	# === Ground jump ===
	if is_on_floor() and jump_buffer_time > 0.0:
		velocity.y = -JUMP_VELOCITY
		jump_buffer_time = 0.0
		jump_dust_particles.restart()
		jump_dust_particles.emitting = true
		jump_sfx.play()
		_squash_stretch(0.8, 1.2)

	# === Landed this frame ===
	if not was_on_floor and is_on_floor():
		_squash_stretch(1.3, 0.7)
		land_sfx.play()

	was_on_floor = is_on_floor()

	# === Move and Slide ===
	move_and_slide()

	# === Run Dust ===
	if is_on_floor() and abs(velocity.x) > 20:
		if velocity.x > 0:
			run_dust_right.emitting = true
			run_dust_left.emitting = false
		else:
			run_dust_left.emitting = true
			run_dust_right.emitting = false
	else:
		run_dust_left.emitting = false
		run_dust_right.emitting = false

func _squash_stretch(x_scale: float, y_scale: float):
	sprite.scale = Vector2(x_scale, y_scale)
	create_tween().tween_property(sprite, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
