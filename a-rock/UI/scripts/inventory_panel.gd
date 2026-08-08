extends Control
signal back_requested

const CHARACTER_TAB_SCENE := preload("res://UI/scenes/CharacterTabButton.tscn")

@onready var consumable_tab_button: Button = $CateroryTabs/ConsumableTabButton
@onready var material_tab_button: Button = $CateroryTabs/MaterialTabButton
@onready var key_tab_button: Button = $CateroryTabs/KeyTabButton
@onready var item_list_container: VBoxContainer = $ItemListContainer
@onready var description_label: Label = $DescriptionLabel
@onready var character_tabs: HBoxContainer = $CharacterTabs
@onready var back_button: Button = $BackButton

var current_category: InventoryItem.ItemCategory = InventoryItem.ItemCategory.CONSUMABLE
var item_buttons: Array[Button] = []
var character_tab_buttons: Array[Button] = []
var selected_item: InventoryItem


func _ready() -> void:
	consumable_tab_button.pressed.connect(func(): _set_category(InventoryItem.ItemCategory.CONSUMABLE))
	material_tab_button.pressed.connect(func(): _set_category(InventoryItem.ItemCategory.MATERIAL))
	key_tab_button.pressed.connect(func(): _set_category(InventoryItem.ItemCategory.KEY))
	back_button.pressed.connect(func(): back_requested.emit())


func refresh() -> void:
	_populate_character_tabs()
	_set_category(InventoryItem.ItemCategory.CONSUMABLE)


func grab_initial_focus() -> void:
	consumable_tab_button.grab_focus()


func _populate_character_tabs() -> void:
	for child in character_tabs.get_children():
		child.free()
	character_tab_buttons.clear()

	for character in GameData.party:
		var tab := CHARACTER_TAB_SCENE.instantiate()
		character_tabs.add_child(tab)
		tab.set_character(character)
		tab.character_selected.connect(_on_target_clicked)
		character_tab_buttons.append(tab)

	character_tabs.hide()


func _set_category(category: InventoryItem.ItemCategory) -> void:
	current_category = category
	selected_item = null
	character_tabs.hide()
	description_label.text = ""
	_populate_item_list()


func _populate_item_list() -> void:
	for child in item_list_container.get_children():
		child.free()
	item_buttons.clear()

	for item in Database.all_items:
		if item.category != current_category:
			continue

		var count :int = GameData.get_item_count(item)
		if count <= 0:
			continue

		var button := Button.new()
		button.text = "%s x%d" % [item.item_name, count]
		button.icon = item.icon
		button.toggle_mode = true
		button.custom_minimum_size = Vector2(0, 40)

		item_list_container.add_child(button)
		item_buttons.append(button)
		button.pressed.connect(_on_item_clicked.bind(item, button))

	if item_buttons.is_empty():
		description_label.text = "Aucun objet dans cette catégorie."


func _on_item_clicked(item: InventoryItem, button: Button) -> void:
	selected_item = item
	description_label.text = item.description

	for b in item_buttons:
		b.button_pressed = (b == button)

	var usable := item.is_usable_in(GameManager.GameState.EXPLORATION) and item.effect != null

	if usable:
		character_tabs.show()
		if not character_tab_buttons.is_empty():
			character_tab_buttons[0].grab_focus()
	else:
		character_tabs.hide()


func _on_target_clicked(character: CharacterInstance) -> void:
	if selected_item == null or selected_item.effect == null:
		return

	selected_item.effect.execute(character, { "target": character })
	character.resync_attributes()

	GameData.remove_item(selected_item)

	_populate_item_list()
	character_tabs.hide()
	selected_item = null
	description_label.text = "%s utilisé sur %s." % [selected_item.item_name if selected_item else "Objet", character.character_name]
