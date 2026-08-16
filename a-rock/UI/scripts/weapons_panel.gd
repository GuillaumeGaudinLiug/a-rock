extends Control
signal back_requested

const CHARACTER_TAB_SCENE := preload("res://UI/scenes/CharacterTabButton.tscn")

@onready var character_tabs: HBoxContainer = $CharacterTabs
@onready var weapon_list_container: VBoxContainer = $WeaponListContainer
@onready var stats_preview: VBoxContainer = $StatsPreview
@onready var cost_label: Label = $CostLabel

@onready var equip_button: Button = $EquipButton
@onready var level_up_button: Button = $LevelUpButton
@onready var back_button: Button = $BackButton
@onready var material_icon: TextureRect = $MaterialIcon  # ajuste le chemin selon ta structure

var selected_character: CharacterInstance
var selected_weapon: Weapon
var character_tab_buttons: Array[Button] = []
var weapon_buttons: Array[Button] = []


func _ready() -> void:
	equip_button.pressed.connect(_on_equip_pressed)
	level_up_button.pressed.connect(_on_level_up_pressed)
	back_button.pressed.connect(func(): back_requested.emit())


func refresh() -> void:
	for child in character_tabs.get_children():
		child.queue_free()
	character_tab_buttons.clear()

	for character in GameData.party:
		var tab := CHARACTER_TAB_SCENE.instantiate()
		character_tabs.add_child(tab)
		tab.set_character(character)
		tab.character_selected.connect(_on_character_selected)
		character_tab_buttons.append(tab)

	if not GameData.party.is_empty():
		_on_character_selected(GameData.party[0])
		character_tab_buttons[0].button_pressed = true


func grab_initial_focus() -> void:
	if not character_tab_buttons.is_empty():
		character_tab_buttons[0].grab_focus()


func _on_character_selected(character: CharacterInstance) -> void:
	selected_character = character

	for tab in character_tab_buttons:
		tab.button_pressed = (tab.character == character)

	_populate_weapon_list()


func _populate_weapon_list() -> void:
	for child in weapon_list_container.get_children():
		child.queue_free()
	weapon_buttons.clear()

	for weapon in Database.all_weapons:
		var level: int = selected_character.weapon_levels.get(weapon, 0)

		var button := Button.new()
		button.text = "%s — Niveau %d / %d" % [weapon.weapon_name, level, weapon.max_level]
		button.toggle_mode = true
		button.custom_minimum_size = Vector2(0, 40)
		button.add_theme_font_size_override("font_size", 20)
		button.icon = weapon.icon

		weapon_list_container.add_child(button)
		weapon_buttons.append(button)
		button.pressed.connect(_on_weapon_selected.bind(weapon, button))

	if not Database.all_weapons.is_empty():
		_on_weapon_selected(Database.all_weapons[0], weapon_buttons[0])


func _on_weapon_selected(weapon: Weapon, button: Button) -> void:
	selected_weapon = weapon

	for b in weapon_buttons:
		b.button_pressed = (b == button)

	_update_preview()

# Affiche les détails d'une arme selectionnée
func _update_preview() -> void:
	for child in stats_preview.get_children():
		child.free()

	var current_level: int = selected_character.weapon_levels.get(selected_weapon, 0)
	var next_level := current_level + 1
	var is_max := current_level >= selected_weapon.max_level

	material_icon.hide()

	# Max level
	if is_max:
		cost_label.text = "Niveau maximum atteint."
		level_up_button.disabled = true
	else:
		# Non définition
		var entry := selected_weapon.get_level_entry(next_level)
		if entry == null:
			cost_label.text = "Coût non défini pour ce niveau."
			level_up_button.disabled = true
		# Verification d'xp et de requiredMaterial
		else:
			var has_enough_xp := GameData.xp_global >= entry.xp_required
			var has_enough_material := true

			var text := "Passage au niveau %d : %d XP (vous avez %d XP)" % [next_level, entry.xp_required, GameData.xp_global]

			if entry.required_material != null:
				var owned := GameData.get_item_count(entry.required_material)
				has_enough_material = owned >= entry.required_material_quantity
				text += "\nRequiert : %s x%d (possédé : %d)" % [entry.required_material.item_name, entry.required_material_quantity, owned]
				material_icon.texture = entry.required_material.icon
				material_icon.show()

			cost_label.text = text
			level_up_button.disabled = not (has_enough_xp and has_enough_material)

			for stat_name in ["determination", "courage", "passion", "spirit", "adaptability", "max_ep", "max_sp"]:
				var before := selected_weapon.get_stat_bonus(stat_name, current_level)
				var after := selected_weapon.get_stat_bonus(stat_name, next_level)
				var label := Label.new()
				if before != after:
					label.text = "%s : %d → %d (+%d)" % [stat_name.capitalize(), before, after, after - before]
				else:
					label.text = "%s : %d (inchangé)" % [stat_name.capitalize(), before]
				stats_preview.add_child(label)

	equip_button.disabled = (selected_character.equipped_weapon == selected_weapon)
	equip_button.text = "Équipé" if equip_button.disabled else "Équiper"

func _on_equip_pressed() -> void:
	if not selected_character.weapon_levels.has(selected_weapon):
		selected_character.weapon_levels[selected_weapon] = 0
	selected_character.equipped_weapon = selected_weapon
	selected_character.resync_attributes()
	_update_preview()


func _on_level_up_pressed() -> void:
	if selected_character.try_level_up_weapon(selected_weapon):
		_populate_weapon_list()
