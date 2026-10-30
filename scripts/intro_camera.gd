extends Path2D

@export var fly_time: float = 4.5
@export var return_time: float = 1.5
@export var skip_intro: bool = false
@export var path_follow: PathFollow2D

func _ready() -> void:
	if skip_intro:
		return
	
	play_intro()

func play_intro() -> void:
	path_follow.progress_ratio = 0.0
	GameCamera.lock_to_node(path_follow, 100.0)
	
	var fly_tween: Tween = create_tween()
	fly_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	fly_tween.tween_property(path_follow, "progress_ratio", 1.0, fly_time)
	await fly_tween.finished
	
	GameCamera.unlock_position(3.0)
	await get_tree().create_timer(return_time).timeout
