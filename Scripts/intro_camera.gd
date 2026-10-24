extends Path2D
## Кинематографичный пролёт камеры в начале уровня.
## Камера-«оператор» летит по нарисованной траектории (Path2D),
## потом возвращается к игроку и отдаёт ему управление.

@export var player: Player
@export var player_camera: Camera2D
## Сколько секунд камера летит по траектории
@export var fly_time: float = 5.0
## Сколько секунд камера возвращается к игроку
@export var return_time: float = 1.5
## Галочка для разработчика: пропустить пролёт, чтобы не ждать каждый запуск
@export var skip_intro: bool = false

@onready var path_follow: PathFollow2D = $PathFollow
@onready var intro_camera: Camera2D = $PathFollow/IntroCamera


func _ready() -> void:
	if skip_intro:
		return
	
	# Автопоиск игрока и его камеры, если они не заданы вручную в инспекторе
	if not player:
		player = get_tree().get_first_node_in_group("player") as Player
	if not player_camera and player:
		player_camera = player.find_child("Camera") as Camera2D
		if not player_camera:
			player_camera = player.get_node_or_null("Camera2D")
			
	if not player or not player_camera:
		return
		
	play_intro()


func play_intro() -> void:
	# 1. Забираем управление у игрока и включаем камеру-оператора
	player.can_move = false
	intro_camera.make_current()
	path_follow.progress_ratio = 0.0

	# 2. Летим по траектории от начала (0.0) до конца (1.0)
	var fly_tween: Tween = create_tween()
	fly_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	fly_tween.tween_property(path_follow, "progress_ratio", 1.0, fly_time)
	await fly_tween.finished

	# 3. Плавно подлетаем туда, куда смотрит камера игрока
	var return_tween: Tween = create_tween()
	return_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	return_tween.tween_property(intro_camera, "global_position", get_player_view_center(), return_time)
	await return_tween.finished

	# 4. Переключаемся на камеру игрока и возвращаем управление
	player_camera.make_current()
	player_camera.reset_smoothing()
	player.can_move = true


## Точка, в которую смотрит камера игрока (с учётом границ уровня)
func get_player_view_center() -> Vector2:
	var half_screen: Vector2 = get_viewport_rect().size / player_camera.zoom / 2.0
	var center: Vector2 = player_camera.global_position
	center.x = clamp(center.x, player_camera.limit_left + half_screen.x, player_camera.limit_right - half_screen.x)
	center.y = clamp(center.y, player_camera.limit_top + half_screen.y, player_camera.limit_bottom - half_screen.y)
	return center
