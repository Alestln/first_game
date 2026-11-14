class_name Hurtbox
extends Area2D

signal hit_received(knockback: Vector2)

@export var health_component: HealthComponent
@export var receive_knockback: bool = true

func _ready() -> void:
	assert(health_component != null, "%s: 'health_component' обязателен для работы!" % name)

func take_hit(damage: int, knockback: Vector2) -> void:
	if not health_component.take_damage(damage):
		return
	
	var final_knockback: Vector2 = knockback if receive_knockback else Vector2.ZERO
	hit_received.emit(final_knockback)
