extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2
const ROLL_SPEED = 260.0
const ROLL_TIME = 0.25
const ROLL_COOLDOWN = 1.0

const ACCEL = 900.0
const FRICTION = 900.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumps_left = MAX_JUMPS
var is_rolling = false
var roll_direction = 1
var is_invulnerable = false
var current_animation := ""
var can_roll = true

@onready var animated_sprite = $AnimatedSprite2D
@onready var roll_cooldown_bar = $"CanvasLayer/RollCoolDownBar"

func _ready():
	roll_cooldown_bar.value = 100  # start full

func _physics_process(delta):
	# ROLL PHYSICS
	if is_rolling:
		velocity.x = roll_direction * ROLL_SPEED
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return

	# GRAVITY
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jumps_left = MAX_JUMPS

	# JUMP
	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1

	var direction = Input.get_axis("move_left", "move_right")

	# SPRITE FLIP
	animated_sprite.flip_h = direction < 0

	# START ROLL WITH COOLDOWN
	if Input.is_action_just_pressed("roll") and can_roll:
		start_roll()
		return

	# HORIZONTAL MOVEMENT
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# ANIMATION
	var new_animation := current_animation
	if is_on_floor():
		new_animation = "idle" if direction == 0 else "run"
	else:
		new_animation = "jumpc"

	if new_animation != current_animation:
		current_animation = new_animation
		animated_sprite.play(current_animation)

	move_and_slide()

func start_roll():
	is_rolling = true
	is_invulnerable = true
	can_roll = false
	roll_direction = -1 if animated_sprite.flip_h else 1
	roll_cooldown_bar.value = 0
	await get_tree().create_timer(ROLL_TIME).timeout
	is_rolling = false
	is_invulnerable = false
	roll_cooldown_bar_fill()

func roll_cooldown_bar_fill():
	var timer = 0.0
	while timer < ROLL_COOLDOWN:
		timer += get_process_delta_time()
		roll_cooldown_bar.value = (timer / ROLL_COOLDOWN) * 100
		await get_tree().process_frame
	can_roll = true
	roll_cooldown_bar.value = 100

func die():
	animated_sprite.play("death")
	set_process(false)
	set_physics_process(false)
