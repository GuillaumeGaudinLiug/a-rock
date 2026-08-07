# character_tab_button.gd
extends Button

signal character_selected(character: CharacterInstance)

@onready var preview: AnimatedSprite2D = $VBoxContainer/PreviewViewport/SubViewport/AnimatedSprite2D
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var selection_frame: Panel = $SelectionFrame

var character: CharacterInstance


func _ready() -> void:
	pressed.connect(func(): character_selected.emit(character))
	toggled.connect(_on_toggled)
	selection_frame.visible = button_pressed

func _on_toggled(is_pressed: bool) -> void:
	selection_frame.visible = is_pressed

# Transfert du character
func set_character(new_character: CharacterInstance) -> void:
	character = new_character
	name_label.text = character.character_name

	preview.sprite_frames = character.character_class.idle_sprite_frame
	if preview.sprite_frames != null and preview.sprite_frames.has_animation("idle"):
		preview.play("idle")
