class_name DamageZone
extends Area2D

@export var damage: int = 20

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(damage)

