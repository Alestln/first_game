class_name GameCamera
extends Camera2D

static var instance: GameCamera

@export var follow_target: Node2D

@export var follow_speed: float = 6.0

enum Mode {
	FOLLOW_PLAYER,
	LOCKED_TO_POINT,
	FOLLOW_NODE
}

var current_mode: Mode = Mode.FOLLOW_PLAYER
var locked_position: Vector2 = Vector2.ZERO
var target_node: Node2D = null
var current_speed: float = 6.0

func _enter_tree() -> void:
	instance = self

func _exit_tree() -> void:
	if instance == self:
		instance = null

func _ready() -> void:
	top_level = true
	
	assert(follow_target != null, "%s: 'follow_target' обязателен для работы!" % name)
	
	global_position = follow_target.global_position

static func lock_to_position(target_pos: Vector2, speed: float = 4.0) -> void:
	if instance and is_instance_valid(instance):
		instance.set_locked_position(target_pos, speed)

static func unlock_position(speed: float = 5.0) -> void:
	if instance and is_instance_valid(instance):
		instance.return_to_player(speed)

static func lock_to_node(node: Node2D, speed: float = 100.0) -> void:
	if instance and is_instance_valid(instance):
		instance.set_target_node(node, speed)

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

func _physics_process(delta: float) -> void:
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
	
	var weight: float = 1.0 - exp(-current_speed * delta)
	global_position = global_position.lerp(destination, weight)
