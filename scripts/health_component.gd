class_name HealthComponent
extends Node

signal health_changed(current_health: int, max_health: int)

const MIN_HEALTH: int = 0

@export var max_health: int = 100
@export var invincibility_duration: float = 0.8

var _current_health: int = MIN_HEALTH
var _is_invincible: bool = false

var current_health: int:
	get:
		return _current_health

func _enter_tree() -> void:
	_set_health(max_health)

static func get_from(node: Node) -> HealthComponent:
	for child: Node in node.get_children():
		if child is HealthComponent:
			return child
	return null

func take_damage(amount: int) -> void:
	assert(amount > 0, "%s: урон должен быть больше 0 (передано: %d)!" % [name, amount])
	
	if _is_invincible or _current_health <= MIN_HEALTH:
		return
	
	_set_health(_current_health - amount)
	_start_invincibility()

func _set_health(value: int) -> void:
	_current_health = clampi(value, MIN_HEALTH, max_health)
	health_changed.emit(_current_health, max_health)

func _start_invincibility() -> void:
	if invincibility_duration <= 0.0:
		return
	
	_is_invincible = true
	await get_tree().create_timer(invincibility_duration).timeout
	_is_invincible = false
