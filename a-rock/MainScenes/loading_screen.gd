# loading_screen.gd
extends CanvasLayer

@onready var background: ColorRect = $Background


func fade_to_black(duration: float = 0.3) -> void:
	background.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(background, "modulate:a", 1.0, duration)
	await tween.finished


func fade_from_black(duration: float = 0.3) -> void:
	var tween := create_tween()
	tween.tween_property(background, "modulate:a", 0.0, duration)
	await tween.finished
