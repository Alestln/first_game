@tool
class_name CameraFrame
extends Node2D

@export var frame_color: Color = Color(0.2, 0.85, 1.0, 0.9):
	set(value):
		frame_color = value
		queue_redraw()

@export var line_width: float = 2.0:
	set(value):
		line_width = value
		queue_redraw()

func _enter_tree() -> void:
	if Engine.is_editor_hint() and not ProjectSettings.settings_changed.is_connected(queue_redraw):
		ProjectSettings.settings_changed.connect(queue_redraw)

func _exit_tree() -> void:
	if Engine.is_editor_hint() and ProjectSettings.settings_changed.is_connected(queue_redraw):
		ProjectSettings.settings_changed.disconnect(queue_redraw)

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	
	var viewport_size: Vector2 = _get_viewport_size()
	var rect: Rect2 = Rect2(-viewport_size * 0.5, viewport_size)
	
	draw_rect(rect, Color(frame_color, 0.07), true)
	draw_rect(rect, frame_color, false, line_width)
	
	var cross_size: float = 10.0
	draw_line(Vector2(-cross_size, 0.0), Vector2(cross_size, 0.0), frame_color, line_width)
	draw_line(Vector2(0.0, -cross_size), Vector2(0.0, cross_size), frame_color, line_width)

func _get_viewport_size() -> Vector2:
	var width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height: float = ProjectSettings.get_setting("display/window/size/viewport_height")
	return Vector2(width, height)
