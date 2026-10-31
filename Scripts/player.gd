class_name Player
extends CharacterBody2D

signal coins_changed(new_coins: int)
signal health_changed(current_health: int, max_health: int)

const MIN_COINS: int = 0
const MIN_HEALTH: int = 0

static var instance: Player

@export var SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -400.0
@export var max_health: int = 100
@export var animated_sprite: AnimatedSprite2D

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL
}

var current_state: State = State.IDLE

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_move: bool = true

var coins: int = MIN_COINS:
	set(value):
		coins = max(MIN_COINS, value)
		coins_changed.emit(coins)

var health: int = MIN_HEALTH:
	set(value):
		health = clampi(value, MIN_HEALTH, max_health)
		health_changed.emit(health, max_health)

func _enter_tree() -> void:
	assert(instance == null, "На сцене может быть только один экземпляр Player!")
	instance = self
	health = max_health

func _exit_tree() -> void:
	if instance == self:
		instance = null

static func set_movement_enabled(enabled: bool) -> void:
	assert(instance != null, "Player: экземпляр игрока отсутствует на сцене!")
	instance.can_move = enabled

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	health -= amount

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	var direction: float = 0.0
	if can_move:
		handle_jump()
		direction = Input.get_axis("move_left", "move_right")
	
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
