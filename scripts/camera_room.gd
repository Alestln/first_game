class_name CameraRoom
extends Area2D

@export var transition_speed: float = 4.0
@export var focus_point: Marker2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var target: Vector2 = focus_point.global_position
		GameCamera.lock_to_position(target, transition_speed)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		GameCamera.unlock_position(transition_speed)
