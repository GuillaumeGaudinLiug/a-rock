extends Control
signal back_requested

const CHARACTER_TAB_SCENE := preload("res://UI/scenes/CharacterTabButton.tscn")

@onready var caster_tabs: HBoxContainer = $CasterTabs
@onready var skill_list_container: VBoxContainer = $SkillListContainer
@onready var description_label: Label = $DescriptionLabel
@onready var target_tabs: HBoxContainer = $TargetTabs
@onready var back_button: Button = $BackButton

var caster_tab_buttons: Array[Button] = []
var target_tab_buttons: Array[Button] = []
var skill_buttons: Array[Button] = []
var selected_caster: CharacterInstance
var selected_skill: Skill


func _ready() -> void:
	back_button.pressed.connect(func(): back_requested.emit())


func refresh() -> void:
	_populate_caster_tabs()


func grab_initial_focus() -> void:
	if not caster_tab_buttons.is_empty():
		caster_tab_buttons[0].grab_focus()


func _populate_caster_tabs() -> void:
	for child in caster_tabs.get_children():
		child.free()
	caster_tab_buttons.clear()

	for character in GameData.party:
		var tab := CHARACTER_TAB_SCENE.instantiate()
		caster_tabs.add_child(tab)
		tab.set_character(character)
		tab.character_selected.connect(_on_caster_selected)
		caster_tab_buttons.append(tab)

	if not GameData.party.is_empty():
		_on_caster_selected(GameData.party[0])
		caster_tab_buttons[0].button_pressed = true


func _on_caster_selected(character: CharacterInstance) -> void:
	selected_caster = character

	for tab in caster_tab_buttons:
		tab.button_pressed = (tab.character == character)

	selected_skill = null
	description_label.text = ""
	target_tabs.hide()

	_populate_skill_list()


func _populate_skill_list() -> void:
	for child in skill_list_container.get_children():
		child.free()
	skill_buttons.clear()

	for skill in selected_caster.available_skills:
		var button := Button.new()

		var ep_cost := skill.get_ep_cost(selected_caster)
		var sp_cost := skill.get_sp_cost(selected_caster)

		button.text = "%s — EP:%d SP:%d" % [skill.skill_name, ep_cost, sp_cost]
		button.icon = skill.icon

		var usable_here := skill.is_usable_in(GameManager.GameState.EXPLORATION) and not skill.is_passive
		var has_resources := (selected_caster.current_ep >= ep_cost) and (selected_caster.current_sp >= sp_cost)

		button.disabled = not (usable_here and has_resources)

		skill_list_container.add_child(button)
		skill_buttons.append(button)

		button.pressed.connect(_on_skill_clicked.bind(skill, button))
		button.mouse_entered.connect(_on_skill_hovered.bind(skill))

# Selection d'un skill
func _on_skill_clicked(skill: Skill, button: Button) -> void:
	selected_skill = skill
	description_label.text = skill.description

	for b in skill_buttons:
		b.button_pressed = (b == button)

	_populate_target_tabs()
	target_tabs.show()
	if not target_tab_buttons.is_empty():
		target_tab_buttons[0].grab_focus()


func _populate_target_tabs() -> void:
	for child in target_tabs.get_children():
		child.free()
	target_tab_buttons.clear()

	for character in GameData.party:
		var tab := CHARACTER_TAB_SCENE.instantiate()
		target_tabs.add_child(tab)
		tab.set_character(character)
		tab.character_selected.connect(_on_target_clicked)
		target_tab_buttons.append(tab)


func _on_target_clicked(character: CharacterInstance) -> void:
	if selected_skill == null:
		return

	var skill_name := selected_skill.skill_name

	EffectSignalBus.effect_applied.connect(_on_menu_effect_feedback, CONNECT_ONE_SHOT)

	if selected_caster.try_use_skill(selected_skill, { "target": character }):
		description_label.text = "%s utilisé sur %s." % [skill_name, character.character_name]
	else:
		description_label.text = "Impossible d'utiliser %s." % skill_name

	target_tabs.hide()
	selected_skill = null
	_populate_skill_list()

# TODO: feeback
func _on_menu_effect_feedback(target, result: EffectResult) -> void:
	print(result.value_label)  # à remplacer plus tard par une vraie animation/son sur ce menu


func _on_skill_hovered(skill: Skill) -> void:
	description_label.text = skill.description
