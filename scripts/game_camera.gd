class_name GameCamera
extends Camera2D
## Главная кинематографичная камера игры.
##
## Возможности:
## 1. Плавное следование за игроком без привязки к его скейлу (top_level = true)
## 2. Бесшовный переход в режим комнаты (CameraRoom) и обратно без рывков
## 3. Режиссерские пролёты (IntroPath) с плавным возвратом управления
## 4. Кинематографичная тряска (Screen Shake) на основе шума Перлина (FastNoiseLite)
##    с понятными параметрами: сила в пикселях и время в секундах!

static var instance: GameCamera

## За кем следовать по умолчанию (если пусто, автоматически найдёт узел из группы "player")
@export var follow_target: Node2D

## Скорость плавного следования за игроком (чем выше, тем резче)
@export var follow_speed: float = 6.0

## Скорость колебания волны шума при тряске
@export var noise_speed: float = 60.0

enum Mode {
	FOLLOW_PLAYER,
	LOCKED_TO_POINT,
	FOLLOW_NODE
}

var current_mode: Mode = Mode.FOLLOW_PLAYER
var locked_position: Vector2 = Vector2.ZERO
var target_node: Node2D = null
var current_speed: float = 6.0

# --- Параметры шума и тряски ---
var noise: FastNoiseLite = FastNoiseLite.new()
var noise_time: float = 0.0
var max_shake_strength: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0


func _enter_tree() -> void:
	instance = self


func _exit_tree() -> void:
	if instance == self:
		instance = null


func _ready() -> void:
	# Отвязываем камеру от локального скейла и перемещений родителя
	top_level = true
	scale = Vector2.ONE

	# Настройка генератора мягкого шума для естественной тряски
	randomize()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.5

	# Автопоиск игрока, если ссылка не задана в инспекторе
	if not follow_target:
		follow_target = get_parent() as Node2D
		if not follow_target or not (follow_target is Player or follow_target.is_in_group("player")):
			follow_target = get_tree().get_first_node_in_group("player") as Node2D

	if follow_target:
		global_position = follow_target.global_position


# ==============================================================================
# УНИВЕРСАЛЬНЫЕ СТАТИЧЕСКИЕ МЕТОДЫ (вызываются из любого скрипта в 1 строчку)
# ==============================================================================

## Вызов сочной тряски: сила в пикселях, длительность в секундах
## Пример при взятии монеты: GameCamera.shake_current(3.0, 0.15)
## Пример при взрыве бомбы:  GameCamera.shake_current(10.0, 0.5)
static func shake_current(strength: float = 4.0, duration: float = 0.25) -> void:
	if instance and is_instance_valid(instance):
		instance.shake(strength, duration)


## Зафиксировать камеру на координатах комнаты / арены босса
static func lock_to_position(target_pos: Vector2, speed: float = 4.0) -> void:
	if instance and is_instance_valid(instance):
		instance.set_locked_position(target_pos, speed)


## Вернуть камеру к игроку (камера плавно догонит его, куда бы он ни бежал)
static func unlock_position(speed: float = 5.0) -> void:
	if instance and is_instance_valid(instance):
		instance.return_to_player(speed)


## Привязать камеру к любому объекту (тележка в интро, катсцена и т.д.)
static func lock_to_node(node: Node2D, speed: float = 100.0) -> void:
	if instance and is_instance_valid(instance):
		instance.set_target_node(node, speed)


# ==============================================================================
# ВНУТРЕННЕЕ УПРАВЛЕНИЕ КАМЕРОЙ
# ==============================================================================

func shake(strength: float = 4.0, duration: float = 0.25) -> void:
	max_shake_strength = strength
	shake_duration = max(0.01, duration)
	shake_timer = shake_duration


func set_locked_position(target_pos: Vector2, speed: float = 4.0) -> void:
	current_mode = Mode.LOCKED_TO_POINT
	locked_position = target_pos
	current_speed = speed


func return_to_player(speed: float = 5.0) -> void:
	current_mode = Mode.FOLLOW_PLAYER
	current_speed = speed


func set_target_node(node: Node2D, speed: float = 100.0) -> void:
	current_mode = Mode.FOLLOW_NODE
	target_node = node
	current_speed = speed
	if speed >= 50.0 and is_instance_valid(node):
		global_position = node.global_position


func _physics_process(delta: float) -> void:
	# --------------------------------------------------------------------------
	# 1. Кинематографичная тряска экрана
	# --------------------------------------------------------------------------
	if shake_timer > 0.0:
		shake_timer -= delta
		noise_time += delta * noise_speed

		# Плавный спад от 1.0 к 0.0 с квадратичным затуханием (Trauma Curve)
		var progress: float = clamp(shake_timer / shake_duration, 0.0, 1.0)
		var current_amplitude: float = max_shake_strength * (progress * progress)

		# Плавные смещения по осям X и Y на основе шума
		offset = Vector2(
			noise.get_noise_2d(noise_time, 0.0),
			noise.get_noise_2d(0.0, noise_time)
		) * current_amplitude
	else:
		offset = Vector2.ZERO

	# --------------------------------------------------------------------------
	# 2. Определение целевой позиции
	# --------------------------------------------------------------------------
	var destination: Vector2
	match current_mode:
		Mode.LOCKED_TO_POINT:
			destination = locked_position
		Mode.FOLLOW_NODE:
			if is_instance_valid(target_node):
				destination = target_node.global_position
			elif is_instance_valid(follow_target):
				destination = follow_target.global_position
			else:
				return
		Mode.FOLLOW_PLAYER:
			if is_instance_valid(follow_target):
				destination = follow_target.global_position
			else:
				return

	# --------------------------------------------------------------------------
	# 3. Экспоненциальное сглаживание к цели
	# Формула lerp с экспонентой (1 - exp(-speed * delta)) не зависит от скачков FPS
	# --------------------------------------------------------------------------
	var weight: float = 1.0 - exp(-current_speed * delta)
	global_position = global_position.lerp(destination, weight)
