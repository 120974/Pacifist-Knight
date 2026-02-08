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
var is_invulnerable = false
var can_roll = true

var facing := 1
var current_animation := ""

@onready var animated_sprite = $AnimatedSprite2D
@onready var roll_cooldown_bar = $"CanvasLayer/RollCoolDownBar"

func _ready():
	roll_cooldown_bar.value = 100

func _physics_process(delta):
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

	# FACING (NO JITTER)
	if direction != 0:
		facing = direction
		animated_sprite.flip_h = facing < 0

	# START ROLL
	if Input.is_action_just_pressed("roll") and can_roll:
		start_roll()

	# ROLL PHYSICS
	if is_rolling:
		velocity.x = facing * ROLL_SPEED
	else:
		# HORIZONTAL MOVEMENT
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * SPEED, ACCEL * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# ANIMATION (STATE-DRIVEN)
	var new_animation := current_animation
	if is_rolling:
		new_animation = "roll"
	elif not is_on_floor():
		new_animation = "jump"
	elif direction == 0:
		new_animation = "idle"
	else:
		new_animation = "run"

	if new_animation != current_animation:
		current_animation = new_animation
		animated_sprite.play(current_animation)

	move_and_slide()

func start_roll():
	is_rolling = true
	is_invulnerable = true
	can_roll = false
	roll_cooldown_bar.value = 0

	await get_tree().create_timer(ROLL_TIME).timeout

	is_rolling = false
	is_invulnerable = false
	fill_roll_cooldown()

func fill_roll_cooldown():
	var t := 0.0
	while t < ROLL_COOLDOWN:
		t += get_process_delta_time()
		roll_cooldown_bar.value = (t / ROLL_COOLDOWN) * 100
		await get_tree().process_frame

	can_roll = true
	roll_cooldown_bar.value = 100

func die():
	animated_sprite.play("death")
	set_physics_process(false)
	set_process(false)
