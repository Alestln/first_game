extends Area2D
## Комната со статичной камерой (как арена босса или секретная комната).
## Пока игрок внутри зоны, камера стоит на месте и показывает всю комнату.

@export var room_camera: Camera2D
@export var player_camera: Camera2D
## За сколько секунд камера переезжает в комнату
@export var transition_time: float = 0.6

## Где камера комнаты должна стоять (запоминаем при старте)
var room_view_position: Vector2


func _ready() -> void:
	room_view_position = room_camera.global_position


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# Ставим камеру комнаты туда, куда сейчас смотрит игрок, и включаем её
		room_camera.global_position = player_camera.get_screen_center_position()
		room_camera.make_current()
		# Плавно переезжаем в центр комнаты
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(room_camera, "global_position", room_view_position, transition_time)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		# Возвращаем камеру игрока (сглаживание само плавно догонит игрока)
		player_camera.make_current()
