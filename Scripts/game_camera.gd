class_name GameCamera
extends Camera2D
## Главная универсальная кинематографичная камера игры.
## Особенности:
## 1. Автономное плавное следование за игроком (без привязки к скейлу персонажа)
## 2. Фиксация на комнатах/аренах без резких скачков (плавный вход И плавный выход)
## 3. Режиссерские пролеты (катсцены) через привязку к любому объекту
## 4. Сочная тряска (screen shake) из любой точки игры: GameCamera.shake_current(2.0)

static var instance: GameCamera

## За кем следовать по умолчанию (если пусто, автоматически найдет игрока в группе "player")
@export var follow_target: Node2D

## Скорость плавного следования за игроком
@export var follow_speed: float = 6.0

## Скорость затухания тряски
@export var shake_decay: float = 20.0

enum Mode {
	FOLLOW_PLAYER,
	LOCKED_TO_POINT,
	FOLLOW_NODE
}

var current_mode: Mode = Mode.FOLLOW_PLAYER
var locked_position: Vector2 = Vector2.ZERO
var target_node: Node2D = null
var current_speed: float = 6.0
var shake_strength: float = 0.0


func _enter_tree() -> void:
	instance = self


func _exit_tree() -> void:
	if instance == self:
		instance = null


func _ready() -> void:
	# Отвязываем камеру от локальных трансформаций и скейла родителя
	top_level = true
	scale = Vector2.ONE
	
	if not follow_target:
		follow_target = get_parent() as Node2D
		if not follow_target or not (follow_target is Player or follow_target.is_in_group("player")):
			follow_target = get_tree().get_first_node_in_group("player") as Node2D

	if follow_target:
		global_position = follow_target.global_position


## --- Универсальные статические методы ---

## Вызов тряски: GameCamera.shake_current(3.0)
static func shake_current(strength: float = 4.0) -> void:
	if instance and is_instance_valid(instance):
		instance.shake(strength)


## Зафиксировать камеру в центре комнаты / на точке
static func lock_to_position(target_pos: Vector2, speed: float = 4.0) -> void:
	if instance and is_instance_valid(instance):
		instance.set_locked_position(target_pos, speed)


## Вернуть камеру к игроку (плавно догоняет игрока, куда бы он ни бежал!)
static func unlock_position(speed: float = 5.0) -> void:
	if instance and is_instance_valid(instance):
		instance.return_to_player(speed)


## Привязать камеру к любому узлу (например, к PathFollow во время пролета)
static func lock_to_node(node: Node2D, speed: float = 100.0) -> void:
	if instance and is_instance_valid(instance):
		instance.set_target_node(node, speed)


## --- Внутренние методы управления ---

func shake(strength: float = 4.0) -> void:
	shake_strength = max(shake_strength, strength)


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
	# 1. Тряска экрана
	if shake_strength > 0.0:
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_strength
		shake_strength = move_toward(shake_strength, 0.0, shake_decay * delta)
	else:
		offset = Vector2.ZERO

	# 2. Определение целевой точки
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

	# 3. Экспоненциальное сглаживание: идеальная кино-плавность без привязки к FPS
	var weight: float = 1.0 - exp(-current_speed * delta)
	global_position = global_position.lerp(destination, weight)
