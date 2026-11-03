class_name HeartsBar
extends HBoxContainer

@export var health_component: HealthComponent
@export var full_heart_texture: Texture2D
@export var empty_heart_texture: Texture2D

func _ready() -> void:
	assert(health_component != null, "%s: 'health_component' обязателен для работы!" % name)
	assert(full_heart_texture != null, "%s: 'full_heart_texture' обязателен для работы!" % name)
	assert(empty_heart_texture != null, "%s: 'empty_heart_texture' обязателен для работы!" % name)
	
	health_component.health_changed.connect(_on_health_changed)
	_on_health_changed(health_component.get_health(), health_component.get_max_health())

func _on_health_changed(current_health: int, max_health: int) -> void:
	_sync_hearts_count(max_health)
	
	for i: int in range(max_health):
		var heart_icon: TextureRect = get_child(i) as TextureRect
		if i < current_health:
			heart_icon.texture = full_heart_texture
		else:
			heart_icon.texture = empty_heart_texture

func _sync_hearts_count(target_count: int) -> void:
	while get_child_count() < target_count:
		var heart_icon: TextureRect = TextureRect.new()
		heart_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(heart_icon)
	
	while get_child_count() > target_count:
		var last_index: int = get_child_count() - 1
		var extra_heart: Node = get_child(last_index)
		remove_child(extra_heart)
		extra_heart.queue_free()
