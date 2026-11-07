extends Area2D

@export var damage: int = 1

func _physics_process(_delta: float) -> void:
	if not has_overlapping_bodies():
		return
	
	for body: Node2D in get_overlapping_bodies():
		var health: HealthComponent = HealthComponent.get_from(body)
		if health != null:
			health.take_damage(damage)
