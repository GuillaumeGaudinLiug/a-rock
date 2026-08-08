extends HBoxContainer

signal row_toggled

@export var back_row_offset: Vector2 = Vector2(25, 0)

@onready var preview: AnimatedSprite2D = $PreviewViewport/SubViewport/AnimatedSprite2D
@onready var name_label: Label = $InfoColumn/NameLabel
@onready var ep_bar: ProgressBar = $InfoColumn/EPRow/EPBar
@onready var ep_label: Label = $InfoColumn/EPRow/EPLabel
@onready var sp_bar: ProgressBar = $InfoColumn/SPRow/SPBar
@onready var sp_label: Label = $InfoColumn/SPRow/SPLabel

var default_preview_position: Vector2
var character: CharacterInstance


func _ready() -> void:
	default_preview_position = preview.position
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)


func set_character(new_character: CharacterInstance) -> void:
	character = new_character
	name_label.text = character.character_name

	preview.sprite_frames = character.character_class.idle_sprite_frame
	if preview.sprite_frames != null and preview.sprite_frames.has_animation("idle"):
		preview.play("idle")

	_update_row_offset()

	ep_bar.max_value = character.max_ep
	ep_bar.value = character.current_ep
	ep_label.text = "%d / %d" % [character.current_ep, character.max_ep]

	sp_bar.max_value = character.max_sp
	sp_bar.value = character.current_sp
	sp_label.text = "%d / %d" % [character.current_sp, character.max_sp]


func _update_row_offset() -> void:
	preview.position = default_preview_position + (back_row_offset if character.row == CharacterInstance.PartyRow.BACK else Vector2.ZERO)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_toggle_row()


func _toggle_row() -> void:
	if character == null:
		return
	character.row = CharacterInstance.PartyRow.BACK if character.row == CharacterInstance.PartyRow.FRONT else CharacterInstance.PartyRow.FRONT
	_update_row_offset()
	row_toggled.emit()
