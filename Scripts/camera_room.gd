class_name CameraRoom
extends Area2D
## Универсальная комната со статичной камерой (для арены босса, секретов, отдельных комнат).
## Автоматически и плавно переключает камеру при входе И при выходе игрока.

## Камера комнаты (если не указана, найдет дочерний узел Camera2D)
@export var room_camera: Camera2D

## Камера игрока (необязательно: если не указана, найдет текущую активную камеру сама)
@export var player_camera: Camera2D

## Время плавного перехода камеры (в секундах)
@export var transition_time: float = 0.6

var room_view_position: Vector2
var active_tween: Tween
var is_player_inside: bool = false


func _ready() -> void:
	# Автопоиск дочерней камеры комнаты, если не привязана вручную
	if not room_camera:
		room_camera = get_node_or_null("RoomCamera")
		if not room_camera:
			room_camera = get_node_or_null("Camera2D")
	
	if room_camera:
		room_view_position = room_camera.global_position


func _on_body_entered(body: Node2D) -> void:
	if not (body is Player or body.is_in_group("player")):
		return
	
	is_player_inside = true

	# Если целевая камера игрока еще не сохранена, берем текущую активную
	if not player_camera or not is_instance_valid(player_camera):
		player_camera = get_viewport().get_camera_2d()
	
	if not room_camera:
		return
	
	# Останавливаем предыдущую анимацию, если игрок быстро вошел-вышел
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	# 1. Ставим камеру комнаты туда, где сейчас находится кадр игрока
	if player_camera:
		room_camera.global_position = player_camera.get_screen_center_position()
	
	# 2. Включаем камеру комнаты
	room_camera.make_current()
	
	# 3. Плавно перемещаем её в центр комнаты
	active_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(room_camera, "global_position", room_view_position, transition_time)


func _on_body_exited(body: Node2D) -> void:
	if not (body is Player or body.is_in_group("player")):
		return
	
	is_player_inside = false
	
	if not room_camera or not player_camera:
		return
	
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	# ПЛАВНЫЙ ВЫХОД:
	# 1. Камера комнаты плавно летит назад к позиции игрока
	active_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(room_camera, "global_position", player_camera.global_position, transition_time)
	
	# 2. Только когда камера долетела до игрока — переключаем на камеру игрока
	await active_tween.finished
	
	# Проверяем, что игрок не вернулся назад в комнату во время полета
	if not is_player_inside and is_instance_valid(player_camera):
		player_camera.make_current()
		player_camera.reset_smoothing()
