extends Path2D
## Кинематографичный пролёт камеры в начале уровня.
## Главная камера плавно летит по нарисованной траектории (Path2D),
## а затем мягко возвращается к игроку и передает ему управление.

## Сколько секунд камера летит по траектории
@export var fly_time: float = 4.5
## Сколько секунд камера возвращается к игроку
@export var return_time: float = 1.5
## Галочка для быстрой отладки: пропустить пролёт
@export var skip_intro: bool = false

@onready var path_follow: PathFollow2D = $PathFollow


func _ready() -> void:
	if skip_intro:
		return
	play_intro()


func play_intro() -> void:
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player:
		player.can_move = false

	# 1. Привязываем главную камеру к тележке PathFollow и мгновенно ставим в начало пути
	path_follow.progress_ratio = 0.0
	GameCamera.lock_to_node(path_follow, 100.0)

	# 2. Летим по нарисованной траектории
	var fly_tween: Tween = create_tween()
	fly_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	fly_tween.tween_property(path_follow, "progress_ratio", 1.0, fly_time)
	await fly_tween.finished

	# 3. Плавно возвращаем камеру к игроку
	GameCamera.unlock_position(3.0)
	await get_tree().create_timer(return_time).timeout

	# 4. Отдаем управление игроку
	if player:
		player.can_move = true
