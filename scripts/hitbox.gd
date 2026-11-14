class_name Hitbox
extends Area2D

const LEFT_DIRECTION: float = -1.0
const RIGHT_DIRECTION: float = 1.0

@export var damage: int = 1
@export var knockback_force: float = 220.0
@export var knockback_up_force: float = 180.0
@export var active_by_default: bool = true
@export var collision_shape: CollisionShape2D

func _ready() -> void:
	set_active(active_by_default)

func _physics_process(_delta: float) -> void:
	if not monitoring or not has_overlapping_areas():
		return
	
	for area: Area2D in get_overlapping_areas():
		if area is Hurtbox and (owner == null or area.owner != owner):
			var hurtbox: Hurtbox = area as Hurtbox
			var knockback: Vector2 = get_knockback_vector(hurtbox.global_position)
			hurtbox.take_hit(damage, knockback)

func set_active(active: bool) -> void:
	monitoring = active
	visible = active
	if collision_shape != null:
		collision_shape.set_deferred("disabled", not active)

func get_knockback_vector(target_position: Vector2) -> Vector2:
	var direction_x: float = LEFT_DIRECTION if target_position.x < global_position.x else RIGHT_DIRECTION
	return Vector2(direction_x * knockback_force, -knockback_up_force)
