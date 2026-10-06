extends CharacterBody2D

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL
}

var current_state: State = State.IDLE

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	
	var direction: float = Input.get_axis("move_left", "move_right")
	handle_movement(direction)
	
	move_and_slide()
	
	handle_flip(direction)
	update_state(direction)
	play_animation()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func handle_movement(direction: float) -> void:
	velocity.x = direction * SPEED

func handle_flip(direction: float) -> void:
	if direction > 0.0:
		animated_sprite.flip_h = false
	elif direction < 0.0:
		animated_sprite.flip_h = true

func update_state(direction: float) -> void:
	if is_on_floor():
		if direction == 0.0:
			current_state = State.IDLE
		else:
			current_state = State.RUN
	else:
		if velocity.y < 0.0:
			current_state = State.JUMP
		else:
			current_state = State.FALL

func play_animation() -> void:
	match current_state:
		State.IDLE: 
			animated_sprite.play("idle")
		State.RUN:
			animated_sprite.play("run")
		State.JUMP:
			animated_sprite.play("jump")
		State.FALL:
			animated_sprite.play("fall")
