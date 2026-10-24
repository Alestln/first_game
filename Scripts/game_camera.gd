class_name GameCamera
extends Camera2D
## Камера игрока, которая умеет трястись (удар, взрыв, сбор монетки).

## Как быстро тряска затухает (больше = короче тряска)
@export var shake_decay: float = 20.0

## Текущая сила тряски в пикселях
var shake_strength: float = 0.0


## Вызови camera.shake(5.0) — и экран вздрогнет
func shake(strength: float = 4.0) -> void:
	shake_strength = max(shake_strength, strength)


func _process(delta: float) -> void:
	if shake_strength > 0.0:
		# Каждый кадр сдвигаем картинку в случайную сторону
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_strength
		shake_strength = move_toward(shake_strength, 0.0, shake_decay * delta)
	else:
		offset = Vector2.ZERO
