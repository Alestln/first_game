class_name CameraRoom
extends Area2D

@export var transition_speed: float = 2.0
@export var camera_frame: CameraFrame

func _ready() -> void:
	assert(camera_frame != null, "%s: 'camera_frame' обязателен для работы!" % name)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GameCamera.lock_to_position(camera_frame.global_position, transition_speed)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		GameCamera.unlock_position(transition_speed)
