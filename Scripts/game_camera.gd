class_name GameCamera
extends Camera2D
## Камера с поддержкой сочной тряски (screen shake).
## Работает как самостоятельно, так и глобально через GameCamera.shake_current().

static var current_camera: GameCamera

## Как быстро тряска затухает (больше = короче тряска)
@export var shake_decay: float = 20.0

## Текущая сила тряски в пикселях
var shake_strength: float = 0.0


func _enter_tree() -> void:
	add_to_group("cameras")
	current_camera = self


func _exit_tree() -> void:
	if current_camera == self:
		current_camera = null


## Универсальный статический метод: вызывается из ЛЮБОЙ точки игры в одну строчку:
## GameCamera.shake_current(2.5)
static func shake_current(strength: float = 4.0) -> void:
	if current_camera and is_instance_valid(current_camera):
		current_camera.shake(strength)


## Вызов на конкретном экземпляре
func shake(strength: float = 4.0) -> void:
	shake_strength = max(shake_strength, strength)


func _process(delta: float) -> void:
	if shake_strength > 0.0:
		# Сдвигаем экран в случайную сторону через offset
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_strength
		shake_strength = move_toward(shake_strength, 0.0, shake_decay * delta)
	else:
		offset = Vector2.ZERO
