class_name Hurtbox
extends Area2D

signal hit_received(knockback: Vector2)

@export var health_component: HealthComponent

func _ready() -> void:
	assert(health_component != null, "%s: 'health_component' обязателен для работы!" % name)

func take_hit(damage: int, knockback: Vector2) -> void:
	if health_component.take_damage(damage):
		hit_received.emit(knockback)

