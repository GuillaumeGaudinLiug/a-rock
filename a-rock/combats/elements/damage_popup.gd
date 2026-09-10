extends Node2D

@onready var label: Label = $Label
@onready var icon_rect: TextureRect = $IconRect


func setup(text: String, color: Color, icon: Texture2D = null) -> void:
	label.text = text
	label.modulate = color

	if icon != null:
		icon_rect.texture = icon
		icon_rect.show()
	else:
		icon_rect.hide()

# Fait apparaitre la popup, la deplace sur l'axe puis la cache
func play() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 25, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.6).set_delay(0.5)
	tween.tween_property(icon_rect, "modulate:a", 0.0, 0.6).set_delay(0.5)
	tween.chain().tween_callback(queue_free)
