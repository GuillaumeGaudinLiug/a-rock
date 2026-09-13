extends Control

signal action_confirmed(action: CombatAction)

@onready var skill_list_container: VBoxContainer = $SkillListContainer
@onready var item_list_container: VBoxContainer = $ItemListContainer

@onready var skills_tab: Button = $CategoryTabs/SkillsTabButton
@onready var items_tab: Button = $CategoryTabs/ItemsTabButton
@onready var defend_tab: Button = $CategoryTabs/DefendTabButton
@onready var row_tab: Button = $CategoryTabs/RowTabButton

var combat_scene: Node

var current_actor: CombatParticipant
var allies: Array[CombatParticipant] = []
var enemies: Array[CombatParticipant] = []

var skill_buttons: Array[Button] = []
var item_buttons: Array[Button] = []
var pending_targets_callback: Callable
var target_connections: Array[CombatTargetView] = []


func _ready() -> void:
	skills_tab.pressed.connect(_show_skills)
	items_tab.pressed.connect(_show_items)
	defend_tab.pressed.connect(_on_defend_pressed)
	row_tab.pressed.connect(_on_row_pressed)


func open_for(actor: CombatParticipant, allies_in: Array[CombatParticipant], enemies_in: Array[CombatParticipant], scene: Node) -> void:
	current_actor = actor
	allies = allies_in
	enemies = enemies_in
	combat_scene = scene
	_show_skills()

func _clear_lists() -> void:
	for child in skill_list_container.get_children():
		child.free()
	for child in item_list_container.get_children():
		child.free()
	skill_buttons.clear()
	item_buttons.clear()

	item_list_container.hide()


func _show_skills() -> void:
	_clear_lists()
	skill_list_container.show()
	# Recupere les skills sur le characterInstance
	for skill in current_actor.source_character.available_skills:
		if not skill.is_usable_in(GameManager.GameState.COMBAT):
			continue
		if skill.is_passive:
			continue
		var ep_cost := skill.get_ep_cost(current_actor.source_character)
		var sp_cost := skill.get_sp_cost(current_actor.source_character)

		var button := Button.new()
		button.text = "%s — EP:%d SP:%d" % [skill.skill_name, ep_cost, sp_cost]
		button.icon = current_actor.source_character.get_skill_icon(skill)
		button.disabled = (current_actor.current_ep < ep_cost) or (current_actor.current_sp < sp_cost)

		skill_list_container.add_child(button)
		skill_buttons.append(button)
		button.pressed.connect(_on_skill_chosen.bind(skill))


func _show_items() -> void:
	_clear_lists()
	item_list_container.show()

	for path in GameData.inventory.keys():
		var item: InventoryItem = load(path)
		if item.category != InventoryItem.ItemCategory.CONSUMABLE:
			continue
		if not item.is_usable_in(GameManager.GameState.COMBAT):
			continue

		var count: int = GameData.inventory[path]
		var button := Button.new()
		button.text = "%s x%d" % [item.item_name, count]
		button.icon = item.icon

		item_list_container.add_child(button)
		item_buttons.append(button)
		button.pressed.connect(_on_item_chosen.bind(item))


func _on_skill_chosen(skill: Skill) -> void:
	_begin_targeting(skill.target_scope, func(targets: Array[CombatParticipant]):
		var ep_cost := skill.get_ep_cost(current_actor.source_character)
		var sp_cost := skill.get_sp_cost(current_actor.source_character)

		var action := CombatAction.new()
		action.type = CombatAction.ActionType.SKILL
		action.user = current_actor
		action.targets = targets
		action.effects = skill.effects
		action.skill = skill
		action_confirmed.emit(action)
	)


func _on_item_chosen(item: InventoryItem) -> void:
	_begin_targeting(item.target_scope, func(targets: Array[CombatParticipant]):
		var action := CombatAction.new()
		action.type = CombatAction.ActionType.ITEM
		action.user = current_actor
		action.targets = targets
		action.effects.append_array(item.effects)
		action.item = item
		action_confirmed.emit(action)
	)


func _on_defend_pressed() -> void:
	var action := CombatAction.new()
	action.type = CombatAction.ActionType.DEFEND
	action.user = current_actor
	action.targets = [current_actor]
	#action.effects = CombatConfig.default_defend_effects
	action_confirmed.emit(action)


func _on_row_pressed() -> void:
	var action := CombatAction.new()
	action.type = CombatAction.ActionType.CHANGE_ROW
	action.user = current_actor
	action_confirmed.emit(action)


func _begin_targeting(scope: TargetScope.Type, on_targets_chosen: Callable) -> void:
	_clear_targeting()  # sécurité : nettoie toute connexion résiduelle d'un choix précédent

	var valid_targets := TargetScope.get_valid_targets(scope, current_actor, allies, enemies)

	if TargetScope.is_multi_target(scope) or scope == TargetScope.Type.SELF:
		on_targets_chosen.call(valid_targets)
		return

	pending_targets_callback = on_targets_chosen

	for p in allies + enemies:
		var view: CombatTargetView = combat_scene.view_by_participant[p]
		view.set_targetable(p in valid_targets)
		if p in valid_targets:
			view.target_clicked.connect(_on_target_view_clicked)
			target_connections.append(view)

# En cliquant sur une targetView
func _on_target_view_clicked(clicked: CombatParticipant) -> void:
	_clear_targeting()
	var callback := pending_targets_callback
	pending_targets_callback = Callable()

	var targets: Array[CombatParticipant] = [clicked]
	callback.call(targets)


func _clear_targeting() -> void:
	for view in target_connections:
		view.set_targetable(false)
		if view.target_clicked.is_connected(_on_target_view_clicked):
			view.target_clicked.disconnect(_on_target_view_clicked)
	target_connections.clear()
