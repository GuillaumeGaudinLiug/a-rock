extends Control
signal back_requested

const CHARACTER_TAB_SCENE := preload("res://UI/scenes/CharacterTabButton.tscn")
const STATS := ["determination", "courage", "passion", "spirit", "adaptability"]

@onready var character_tabs: HBoxContainer = $CharacterTabs
@onready var stats_preview: VBoxContainer = $StatsPreview
@onready var class_level_label: Label = $ClassLevelSection/ClassLevelLabel
@onready var class_level_up_button: Button = $ClassLevelSection/ClassLevelUpButton
@onready var back_button: Button = $BackButton
@onready var cost_label: Label = $StatButtons/CostLevel

var stat_buttons: Dictionary = {}
var stat_row_labels: Dictionary = {}
var character_tab_buttons: Array[Button] = []
var selected_character: CharacterInstance


func _ready() -> void:
	for stat_name in STATS:
		var row := $StatButtons.get_node(stat_name.capitalize() + "Row")
		var button: Button = row.get_node("Button")
		stat_buttons[stat_name] = button
		button.pressed.connect(_on_stat_level_up.bind(stat_name))

	class_level_up_button.pressed.connect(_on_class_level_up_pressed)
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

	_update_stats_preview()
	_update_purchase_preview()


func _update_stats_preview() -> void:
	for child in stats_preview.get_children():
		child.free()

	var lines := [
		"Détermination : %d" % selected_character.determination,
		"Courage : %d" % selected_character.courage,
		"Passion : %d" % selected_character.passion,
		"Esprit : %d" % selected_character.spirit,
		"Adaptabilité : %d" % selected_character.adaptability,
		"EP max : %d" % selected_character.max_ep,
		"SP max : %d" % selected_character.max_sp,
	]

	for line in lines:
		var label := Label.new()
		label.text = line
		stats_preview.add_child(label)



func _total_stat_levels() -> int:
	return selected_character.determination_lvl + selected_character.courage_lvl \
		+ selected_character.passion_lvl + selected_character.spirit_lvl \
		+ selected_character.adaptability_lvl


func _update_purchase_preview() -> void:
	var total := _total_stat_levels()
	var cost := LvlConfig.get_stat_level_cost(total)

	for stat_name in STATS:
		var current: int = selected_character.get(stat_name)
		var text := "%d → %d" % [current, current + 1]
		cost_label.text = "%d needed" % cost
		stat_buttons[stat_name].text = text
		stat_buttons[stat_name].disabled = (cost < 0) or (GameData.xp_global < cost)

	var class_cost := LvlConfig.get_stat_level_cost(selected_character.class_level)
	if class_cost < 0:
		class_level_label.text = "Classe niveau %d (maximum)" % selected_character.class_level
		class_level_up_button.disabled = true
	else:
		class_level_label.text = "Classe niveau %d → %d — %d XP" % [selected_character.class_level, selected_character.class_level + 1, class_cost]
		class_level_up_button.disabled = GameData.xp_global < class_cost

func _on_stat_level_up(stat_name: String) -> void:
	if selected_character.try_level_up_stat(stat_name):
		_update_stats_preview()
		_update_purchase_preview()


func _on_class_level_up_pressed() -> void:
	if selected_character.try_level_up_class():
		_update_stats_preview()
		_update_purchase_preview()
