extends Control

@onready var slots: Array[OptionButton] = [$Slot1, $Slot2, $Slot3]
@onready var confirm_button: Button = $ConfirmButton


func _ready() -> void:
	for slot in slots:
		for character_class in Database.all_classes:
			slot.add_item(character_class.class_name_display)

	confirm_button.pressed.connect(_on_confirm_pressed)


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
