class_name CombatAction
extends RefCounted

enum ActionType { SKILL, ITEM, DEFEND, CHANGE_ROW }

@export var default_defend_effect: AbstractEffect

var type: ActionType
var user: CombatParticipant
var targets: Array[CombatParticipant] = []
var effects: Array[AbstractEffect] = []

# Contexte additionnel selon le type (coût EP/SP à vérifier avant exécution, item à retirer après, etc.)
var skill: Skill
var item: InventoryItem


func execute() -> void:
	if type == ActionType.CHANGE_ROW:
		_execute_change_row()
		return

	if effects.is_empty():
		push_warning("CombatAction (%s) sans effects assignés." % ActionType.keys()[type])
		return
	# Applications des effets sur les cibles
	for target in targets:
		for effect in effects:
			var hit := effect.execute({ "user": user, "target": target })
			if not hit:
				break  # les effets suivants ne s'appliquent pas à CETTE cible
		# TODO: Application des status de contre de la cible
		target.trigger_statuses(StatusEffect.TriggerType.ON_HIT_TAKEN, { "user": target, "target": user })


	match type:
		ActionType.SKILL:
			_consume_skill_cost()
		ActionType.ITEM:
			_consume_item()


func _consume_skill_cost() -> void:
	if skill == null:
		return
	user.current_ep -= skill.get_ep_cost(user.source_character) if user.source_character else skill.ep_cost
	user.current_sp -= skill.get_sp_cost(user.source_character) if user.source_character else skill.sp_cost


func _consume_item() -> void:
	if item == null:
		return
	GameData.remove_item(item)


func _execute_change_row() -> void:
	user.row = CharacterInstance.PartyRow.BACK if user.row == CharacterInstance.PartyRow.FRONT else CharacterInstance.PartyRow.FRONT
	print("%s passe en %s" % [user.display_name, "BackRow" if user.row == CharacterInstance.PartyRow.BACK else "FrontRow"])
