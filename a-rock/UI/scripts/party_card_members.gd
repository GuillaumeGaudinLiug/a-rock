# party_member_card.gd
extends HBoxContainer

@onready var preview: AnimatedSprite2D = $PreviewViewport/SubViewport/AnimatedSprite2D
@onready var name_label: Label = $InfoColumn/NameLabel
@onready var ep_bar: ProgressBar = $InfoColumn/EPRow/EPBar
@onready var ep_label: Label = $InfoColumn/EPRow/EPLabel
@onready var sp_bar: ProgressBar = $InfoColumn/SPRow/SPBar
@onready var sp_label: Label = $InfoColumn/SPRow/SPLabel


func set_character(character: CharacterInstance) -> void:
	name_label.text = character.character_name

	preview.sprite_frames = character.character_class.idle_sprite_frame
	if preview.sprite_frames != null and preview.sprite_frames.has_animation("idle"):
		preview.play("idle")

	ep_bar.max_value = character.max_ep
	ep_bar.value = character.current_ep
	ep_label.text = "%d / %d" % [character.current_ep, character.max_ep]

	sp_bar.max_value = character.max_sp
	sp_bar.value = character.current_sp
	sp_label.text = "%d / %d" % [character.current_sp, character.max_sp]
