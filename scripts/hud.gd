class_name HUD
extends CanvasLayer

@export var player: Player
@export var coin_label: Label
@export var health_bar: TextureProgressBar
@export var hearts_bar: HeartsBar
@export var health_tween_duration: float = 0.25

var _health_tween: Tween

func _ready() -> void:
	assert(player != null, "%s: 'player' обязателен для работы!" % name)
	assert(coin_label != null, "%s: 'coin_label' обязателен для работы!" % name)
	assert(health_bar != null, "%s: 'health_bar' обязателен для работы!" % name)
	
	player.coins_changed.connect(_on_coins_changed)
	player.health_changed.connect(_on_health_changed)
	
	_on_coins_changed(player.coins)
	_init_health_display(player.health, player.max_health)

func _init_health_display(current_health: int, max_health: int) -> void:
	health_bar.min_value = Player.MIN_HEALTH
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	if hearts_bar != null:
		hearts_bar.update_hearts(current_health, max_health)

func _on_coins_changed(new_coins: int) -> void:
	coin_label.text = str(new_coins)

func _on_health_changed(current_health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	
	if _health_tween and _health_tween.is_running():
		_health_tween.kill()
	
	_health_tween = create_tween()
	_health_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_health_tween.tween_property(health_bar, "value", float(current_health), health_tween_duration)
	
	if hearts_bar != null:
		hearts_bar.update_hearts(current_health, max_health)

