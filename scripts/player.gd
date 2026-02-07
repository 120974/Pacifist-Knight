extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2
const ROLL_SPEED = 260.0
const ROLL_TIME = 0.25

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumps_left = MAX_JUMPS
var is_rolling = false
var roll_direction = 1
var is_invulnerable = false
var current_animation := ""

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# ROLL PHYSICS (GROUND + AIR)
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
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# START ROLL (GROUND ONLY)
	if Input.is_action_just_pressed("roll") and is_on_floor():
		start_roll()
		return

	# ANIMATION STATE (NO JITTER)
	var new_animation := current_animation

	if is_on_floor():
		if direction == 0:
			new_animation = "idle"
		else:
			new_animation = "run"
	else:
		new_animation = "jumpc"

	if new_animation != current_animation:
		current_animation = new_animation
		animated_sprite.play(current_animation)

	# HORIZONTAL MOVEMENT
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func start_roll():
	is_rolling = true
	is_invulnerable = true

	roll_direction = -1 if animated_sprite.flip_h else 1
	current_animation = "roll"
	animated_sprite.play("jumpc")

	await get_tree().create_timer(ROLL_TIME).timeout

	is_rolling = false
	is_invulnerable = false

func kill():
	if is_invulnerable:
		return

	print("Player died")
	# get_tree().reload_current_scene()
