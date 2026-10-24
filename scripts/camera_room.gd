class_name CameraRoom
extends Area2D
## Универсальная комната со статичной камерой (для арены босса, секреток и отдельных зон).
## При входе плавно переводит главную камеру на комнату, при выходе — плавно возвращает к игроку.
## Никаких рывков и скачков, даже если игрок бежит на полной скорости!

## Точка обзора комнаты (если не указана, берется дочерний узел или центр этой зоны)
@export var view_point: Node2D
## Скорость плавного перехода камеры
@export var transition_speed: float = 4.0


func _ready() -> void:
	# Ищем точку обзора: сначала ViewPoint, потом RoomCamera
	if not view_point:
		view_point = get_node_or_null("ViewPoint")
		if not view_point:
			view_point = get_node_or_null("RoomCamera")


func _on_body_entered(body: Node2D) -> void:
	if body is Player or body.is_in_group("player"):
		var target: Vector2 = view_point.global_position if view_point else global_position
		GameCamera.lock_to_position(target, transition_speed)


func _on_body_exited(body: Node2D) -> void:
	if body is Player or body.is_in_group("player"):
		GameCamera.unlock_position(transition_speed)
