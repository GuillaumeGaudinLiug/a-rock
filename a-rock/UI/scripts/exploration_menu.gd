# exploration_menu.gd
extends CanvasLayer
signal close_requested

const PARTY_CARD_SCENE := preload("res://UI/scenes/PartyCardMembers.tscn")
@onready var party_list: VBoxContainer = $Root/PartyList

@onready var main_panel: VBoxContainer = $Root/MainPanel
@onready var weapons_panel: Control = $Root/WeaponsPanel
@onready var level_stats_panel: Control = $Root/LevelStatsPanel
@onready var return_to_prison_panel: Control = $Root/ReturnToPrisonPanel
@onready var skills_panel: Control = $Root/SkillsPanel
@onready var inventory_panel: Control = $Root/InventoryPanel


@onready var inventory_button: Button = $Root/MainPanel/InventoryButton
@onready var skills_button: Button = $Root/MainPanel/SkillsButton
@onready var weapons_button: Button = $Root/MainPanel/WeaponsButton
@onready var level_stats_button: Button = $Root/MainPanel/LevelStatsButton
@onready var return_button: Button = $Root/MainPanel/ReturnToPrisonButton
@onready var quit_button: Button = $Root/MainPanel/QuitButton


func _ready() -> void:
	weapons_panel.hide()
	level_stats_panel.hide()
	return_to_prison_panel.hide()
	inventory_panel.hide()
	skills_panel.hide()
	main_panel.show()
	
	weapons_button.pressed.connect(func(): _show_panel(weapons_panel))
	level_stats_button.pressed.connect(func(): _show_panel(level_stats_panel))
	return_button.pressed.connect(func(): _show_panel(return_to_prison_panel))
	inventory_button.pressed.connect(func(): _show_panel(inventory_panel))
	skills_button.pressed.connect(func(): _show_panel(skills_panel))


	weapons_panel.back_requested.connect(_show_main_panel)
	level_stats_panel.back_requested.connect(_show_main_panel)
	return_to_prison_panel.back_requested.connect(_show_main_panel)
	inventory_panel.back_requested.connect(_show_main_panel)
	skills_panel.back_requested.connect(_show_main_panel)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		if main_panel.visible:
			close_requested.emit()
		else:
			_show_main_panel()
		get_viewport().set_input_as_handled()


func refresh() -> void:
	_show_main_panel()
	main_panel.get_child(0).grab_focus()


func _show_panel(panel: Control) -> void:
	print(panel.accessibility_name)
	main_panel.hide()
	weapons_panel.hide()
	level_stats_panel.hide()
	return_to_prison_panel.hide()
	inventory_panel.hide()
	skills_panel.hide()
	party_list.hide()

	panel.show()
	panel.refresh()
	panel.grab_initial_focus()


func _show_main_panel() -> void:
	weapons_panel.hide()
	level_stats_panel.hide()
	return_to_prison_panel.hide()
	inventory_panel.hide()
	skills_panel.hide()
	main_panel.show()
	party_list.show()
	_populate_party_list()
	main_panel.get_child(0).grab_focus()


func _populate_party_list() -> void:
	for child in party_list.get_children():
		child.queue_free()

	for character in GameData.party:
		var card := PARTY_CARD_SCENE.instantiate()
		party_list.add_child(card)
		card.set_character(character)
