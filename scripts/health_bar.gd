class_name HealthBar
extends TextureProgressBar

@export var health_component: HealthComponent
@export var tween_duration: float = 0.25

var _health_tween: Tween

func _ready() -> void:
	assert(health_component != null, "%s: 'health_component' обязателен для работы!" % name)
	
	min_value = HealthComponent.MIN_HEALTH
	max_value = health_component.get_max_health()
	value = health_component.get_health()
	
	health_component.health_changed.connect(_on_health_changed)

func _on_health_changed(current_health: int, max_health_value: int) -> void:
	max_value = max_health_value
	
	if _health_tween and _health_tween.is_running():
		_health_tween.kill()
	
	_health_tween = create_tween()
	_health_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_health_tween.tween_property(self, "value", float(current_health), tween_duration)
