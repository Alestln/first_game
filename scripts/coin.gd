extends Area2D

@export var coin_value: int = 1
@export var animated_sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D

var is_collected: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player and not is_collected:
		collect(body)

func collect(player: Player) -> void:
	is_collected = true
	collision_shape.set_deferred("disabled", true)
	
	player.coin_wallet.add_coins(coin_value)
	
	animated_sprite.play("collect")
	
	await animated_sprite.animation_finished
	
	queue_free()
