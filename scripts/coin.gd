extends Area2D

var coin_value: int = 1
var is_collected: bool = false

@export var animated_sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player and not is_collected:
		collect(body)

func collect(player: Player) -> void:
	is_collected = true
	collision_shape.set_deferred("disabled", true)
	
	player.coins += coin_value
	
	animated_sprite.play("collect")
	
	await animated_sprite.animation_finished
	
	queue_free()
