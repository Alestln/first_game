class_name TrainingDummy
extends CharacterBody2D

const HIT_FLASH_INTERVAL: float = 0.1
const HIT_FLASH_ALPHA: float = 0.4

@export var knockback_duration: float = 0.25
@export var knockback_friction: float = 650.0

@export var animated_sprite: AnimatedSprite2D
@export var health_component: HealthComponent
@export var hurtbox: Hurtbox
@export var hitbox: Hitbox

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _knockback_timer: float = 0.0
var _is_destroyed: bool = false
var _hit_tween: Tween

func _ready() -> void:
	assert(animated_sprite != null, "%s: 'animated_sprite' обязателен для работы!" % name)
	assert(health_component != null, "%s: 'health_component' обязателен для работы!" % name)
	assert(hurtbox != null, "%s: 'hurtbox' обязателен для работы!" % name)
	assert(hitbox != null, "%s: 'hitbox' обязателен для работы!" % name)
	
	hurtbox.hit_received.connect(_on_hurtbox_hit_received)
	health_component.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if _knockback_timer > 0.0:
		_knockback_timer = maxf(0.0, _knockback_timer - delta)
	
	velocity.x = move_toward(velocity.x, 0.0, knockback_friction * delta)
	move_and_slide()
	
	if not _is_destroyed:
		if _knockback_timer > 0.0:
			animated_sprite.play("hit")
		else:
			animated_sprite.play("idle")

func _on_hurtbox_hit_received(knockback: Vector2) -> void:
	velocity = knockback
	if _is_destroyed:
		return
	
	_knockback_timer = knockback_duration
	play_hit_flash()

func play_hit_flash() -> void:
	if _hit_tween and _hit_tween.is_running():
		_hit_tween.kill()
	
	animated_sprite.modulate.a = 1.0
	var flash_count: int = maxi(1, int(health_component.invincibility_duration / HIT_FLASH_INTERVAL))
	_hit_tween = create_tween().set_loops(flash_count)
	_hit_tween.tween_property(animated_sprite, "modulate:a", HIT_FLASH_ALPHA, HIT_FLASH_INTERVAL * 0.5)
	_hit_tween.tween_property(animated_sprite, "modulate:a", 1.0, HIT_FLASH_INTERVAL * 0.5)

func _on_died() -> void:
	_is_destroyed = true
	if _hit_tween and _hit_tween.is_running():
		_hit_tween.kill()
	animated_sprite.modulate.a = 1.0
	
	hitbox.set_active(false)
	hurtbox.set_deferred("monitorable", false)
	
	animated_sprite.play("destroy")
	await animated_sprite.animation_finished
	queue_free()
