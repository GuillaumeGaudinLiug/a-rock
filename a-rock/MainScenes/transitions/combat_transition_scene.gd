extends CanvasLayer

@onready var flash: ColorRect = $Flash
@onready var black: ColorRect = $Black
@export var encounter_sfx: AudioStream

func _ready() -> void:
	flash.modulate.a = 0.0
	black.modulate.a = 0.0


func play_intro() -> void:
	SfxManager.play(encounter_sfx)

	var camera := get_tree().get_first_node_in_group("main_camera")
	if camera != null:
		camera.shake(25.0, 0.5)  
	
	var flash_tween := create_tween()
	flash_tween.tween_property(flash, "modulate:a", 1.0, 0.08)
	flash_tween.tween_property(flash, "modulate:a", 0.0, 0.12)
	await flash_tween.finished

	var black_tween := create_tween()
	black_tween.tween_property(black, "modulate:a", 1.0, 1.0)
	await black_tween.finished


func play_outro() -> void:
	var tween := create_tween()
	tween.tween_property(black, "modulate:a", 0.0, 1.0)
	await tween.finished
