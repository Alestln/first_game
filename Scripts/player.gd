class_name Player
extends CharacterBody2D

const FULL_ALPHA: float = 1.0
const HALF_INTERVAL_FACTOR: float = 0.5

static var instance: Player

@export var SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -400.0
@export var attack_duration: float = 0.2
@export var attack_cooldown: float = 0.35
@export var knockback_duration: float = 0.25
@export var knockback_friction: float = 600.0
@export var hit_flash_interval: float = 0.12
@export_range(0.0, 1.0) var hit_flash_alpha: float = 0.35

@export var animated_sprite: AnimatedSprite2D
@export var coin_wallet: CoinWallet
@export var health_component: HealthComponent
@export var hurtbox: Hurtbox
@export var attack_hitbox: Hitbox

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	HURT
}

var current_state: State = State.IDLE

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_move: bool = true

var _attack_timer: float = 0.0
var _attack_cooldown_timer: float = 0.0
var _knockback_timer: float = 0.0
var _hit_tween: Tween

func _enter_tree() -> void:
	assert(instance == null, "На сцене может быть только один экземпляр Player!")
	instance = self

func _exit_tree() -> void:
	if instance == self:
		instance = null

func _ready() -> void:
	assert(animated_sprite != null, "%s: 'animated_sprite' обязателен для работы!" % name)
	assert(coin_wallet != null, "%s: 'coin_wallet' обязателен для работы!" % name)
	assert(health_component != null, "%s: 'health_component' обязателен для работы!" % name)
	assert(hurtbox != null, "%s: 'hurtbox' обязателен для работы!" % name)
	assert(attack_hitbox != null, "%s: 'attack_hitbox' обязателен для работы!" % name)
	
	hurtbox.hit_received.connect(_on_hurtbox_hit_received)
	health_component.died.connect(_on_died)

static func set_movement_enabled(enabled: bool) -> void:
	assert(instance != null, "Player: экземпляр игрока отсутствует на сцене!")
	instance.can_move = enabled

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	update_timers(delta)
	
	var direction: float = 0.0
	if can_move and not is_hurt():
		handle_jump()
		handle_attack()
		direction = Input.get_axis("move_left", "move_right")
	
	handle_movement(direction, delta)
	
	move_and_slide()
	
	handle_flip(direction)
	update_state(direction)
	play_animation()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func update_timers(delta: float) -> void:
	if _attack_cooldown_timer > 0.0:
		_attack_cooldown_timer = maxf(0.0, _attack_cooldown_timer - delta)
	
	if _attack_timer > 0.0:
		_attack_timer = maxf(0.0, _attack_timer - delta)
		if _attack_timer == 0.0:
			stop_attack()
	
	if _knockback_timer > 0.0:
		_knockback_timer = maxf(0.0, _knockback_timer - delta)

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func handle_attack() -> void:
	if Input.is_action_just_pressed("attack") and _attack_cooldown_timer <= 0.0 and not is_attacking():
		start_attack()

func start_attack() -> void:
	_attack_timer = attack_duration
	_attack_cooldown_timer = attack_cooldown
	attack_hitbox.set_active(true)

func stop_attack() -> void:
	_attack_timer = 0.0
	attack_hitbox.set_active(false)

func is_attacking() -> bool:
	return _attack_timer > 0.0

func is_hurt() -> bool:
	return _knockback_timer > 0.0

func handle_movement(direction: float, delta: float) -> void:
	if is_hurt():
		velocity.x = move_toward(velocity.x, 0.0, knockback_friction * delta)
	else:
		velocity.x = direction * SPEED

func handle_flip(direction: float) -> void:
	if is_attacking():
		return
	
	if direction > 0.0:
		animated_sprite.flip_h = false
		attack_hitbox.scale.x = absf(attack_hitbox.scale.x)
	elif direction < 0.0:
		animated_sprite.flip_h = true
		attack_hitbox.scale.x = -absf(attack_hitbox.scale.x)

func update_state(direction: float) -> void:
	if is_hurt():
		current_state = State.HURT
	elif is_attacking():
		current_state = State.ATTACK
	elif is_on_floor():
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
		State.ATTACK:
			animated_sprite.play("attack")
		State.HURT:
			animated_sprite.play("hit")

func _on_hurtbox_hit_received(knockback: Vector2) -> void:
	stop_attack()
	if knockback != Vector2.ZERO:
		velocity = knockback
	_knockback_timer = knockback_duration
	play_hit_flash()

func play_hit_flash() -> void:
	if _hit_tween and _hit_tween.is_running():
		_hit_tween.kill()
	
	animated_sprite.modulate.a = FULL_ALPHA
	if hit_flash_interval <= 0.0 or health_component.invincibility_duration <= 0.0:
		return
	
	var flash_count: int = maxi(1, int(health_component.invincibility_duration / hit_flash_interval))
	var half_step: float = hit_flash_interval * HALF_INTERVAL_FACTOR
	_hit_tween = create_tween().set_loops(flash_count)
	_hit_tween.tween_property(animated_sprite, "modulate:a", hit_flash_alpha, half_step)
	_hit_tween.tween_property(animated_sprite, "modulate:a", FULL_ALPHA, half_step)

func _on_died() -> void:
	get_tree().call_deferred("reload_current_scene")
