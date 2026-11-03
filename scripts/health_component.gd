class_name HealthComponent
extends Node

signal health_changed(current_health: int, max_health: int)

const MIN_HEALTH: int = 0

@export var max_health: int = 100

var _current_health: int = MIN_HEALTH

func _enter_tree() -> void:
	_set_health(max_health)

func get_health() -> int:
	return _current_health

func get_max_health() -> int:
	return max_health

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	_set_health(_current_health - amount)

func _set_health(value: int) -> void:
	_current_health = clampi(value, MIN_HEALTH, max_health)
	health_changed.emit(_current_health, max_health)
