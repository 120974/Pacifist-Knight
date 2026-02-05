extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2
const ROLL_SPEED = 260.0
const ROLL_TIME = 0.35

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumps_left = MAX_JUMPS
var is_rolling = false
var roll_direction = 1

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	if is_rolling:
		velocity.x = roll_direction * ROLL_SPEED
		velocity.y = 0
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jumps_left = MAX_JUMPS

	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1

	var direction = Input.get_axis("move_left", "move_right")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if Input.is_action_just_pressed("roll") and is_on_floor():
		start_roll()
		return

	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func start_roll():
	is_rolling = true
	animated_sprite.play("roll")
	roll_direction = -1 if animated_sprite.flip_h else 1
	await get_tree().create_timer(ROLL_TIME).timeout
	is_rolling = false
