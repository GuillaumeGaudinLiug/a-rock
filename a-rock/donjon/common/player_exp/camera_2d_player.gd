extends Camera2D

var _original_offset := Vector2.ZERO
var _is_shaking := false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		shake(8.0, 0.15)


func shake(intensity: float = 8.0, duration: float = 0.15) -> void:
	if _is_shaking:
		return

	_is_shaking = true
	_original_offset = offset
	var elapsed := 0.0

	while elapsed < duration:
		offset = _original_offset + Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		await get_tree().process_frame
		elapsed += get_process_delta_time()

	offset = _original_offset
	_is_shaking = false
