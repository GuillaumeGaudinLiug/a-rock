extends Control

@onready var slots: Array[OptionButton] = [$VBoxContainer/SlotRow1/Slot1, $VBoxContainer/SlotRow2/Slot2]
@onready var previews: Array[AnimatedSprite2D] = [
	$VBoxContainer/SlotRow1/PreviewViewport1/SubViewport1/Preview1,
	$VBoxContainer/SlotRow2/PreviewViewport2/SubViewport2/Preview2,
]
@onready var confirm_button: Button = $VBoxContainer/ConfirmButton


func _ready() -> void:
	#print("Racine du script: ", self.name, " | scene file: ", scene_file_path)
	#print("VBoxContainer: ", get_node_or_null("VBoxContainer"))
	#print("SlotRow1: ", get_node_or_null("VBoxContainer/SlotRow1"))
	#print("PreviewViewport1: ", get_node_or_null("VBoxContainer/SlotRow1/PreviewViewport1"))
	#print("SubViewport1: ", get_node_or_null("VBoxContainer/SlotRow1/PreviewViewport1/SubViewport1"))
	#print("Preview1: ", get_node_or_null("VBoxContainer/SlotRow1/PreviewViewport1/Preview1"))
	#print("SlotRow2: ", get_node_or_null("VBoxContainer/SlotRow2"))
	#print("PreviewViewport2: ", get_node_or_null("VBoxContainer/SlotRow2/PreviewViewport2"))
	#print("SubViewport2: ", get_node_or_null("VBoxContainer/SlotRow2/PreviewViewport2/SubViewport2"))
	#print("Preview2: ", get_node_or_null("VBoxContainer/SlotRow2/PreviewViewport2/SubViewport2/Preview2"))
	
	for i in slots.size():
		var slot := slots[i]
		for character_class in Database.all_classes:
			print("Character class : " + character_class.class_name_display)
			slot.add_item(character_class.class_name_display)

		slot.item_selected.connect(_on_slot_item_selected.bind(i))
		slot.selected = 0
		_update_preview(i, 0)

	confirm_button.pressed.connect(_on_confirm_pressed)
	slots[0].grab_focus()


func _on_slot_item_selected(index: int, slot_number: int) -> void:
	_update_preview(slot_number, index)


func _update_preview(slot_number: int, class_index: int) -> void:
	print("slot_number=", slot_number, " previews[slot_number]=", previews[slot_number])
	var character_class: CharacterClass = Database.all_classes[class_index]
	var preview := previews[slot_number]
	preview.sprite_frames = character_class.idle_sprite_frame
	if preview.sprite_frames != null and preview.sprite_frames.has_animation("idle"):
		preview.play("idle")

func _on_confirm_pressed() -> void:
	GameData.party.clear()

	for slot in slots:
		var selected_class: CharacterClass = Database.all_classes[slot.selected]
		GameData.party.append(_create_character_instance(selected_class))

	GameManager.goto_scene("res://donjon/prison/prison.tscn")


func _create_character_instance(character_class: CharacterClass) -> CharacterInstance:
	var instance := CharacterInstance.new()
	instance.character_class = character_class
	instance.class_level = 1

	instance.determination_lvl = 0
	instance.courage_lvl = 0
	instance.passion_lvl = 0
	instance.spirit_lvl = 0
	instance.adaptability_lvl = 0

	instance.equipped_weapon = character_class.default_weapon
	instance.weapon_levels = { instance.equipped_weapon: 1 }

	instance.resync_attributes()
	return instance
