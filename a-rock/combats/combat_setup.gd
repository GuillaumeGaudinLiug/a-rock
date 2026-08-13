extends Node

var pending_group: EncounterEnemyGroup
var pending_background: Texture2D
var pending_music: AudioStream

var xp_multiplier: float = 1.0
var loot_multiplier: float = 1.0


func start_encounter(group: EncounterEnemyGroup, background: Texture2D, music: AudioStream) -> void:
	pending_group = group
	pending_background = background
	pending_music = music
	xp_multiplier = 1.0
	loot_multiplier = 1.0
	print("Combat préparé : ", group.group_name, " (", group.members.size(), " ennemis)")
	# TODO : construire les CombatParticipant, puis pour chacun des joueurs :
	# participant.trigger_statuses(StatusEffect.TriggerType.ON_BATTLE_START, { "user": participant })


func resolve_victory(defeated_enemies: Array[EnemyData]) -> void:
	# TODO : construire les CombatParticipant, puis pour chacun des joueurs :
	# participant.trigger_statuses(StatusEffect.TriggerType.ON_BATTLE_END, { "user": participant })

	var total_xp := 0
	for enemy in defeated_enemies:
		total_xp += enemy.xp_value
	total_xp = int(total_xp * xp_multiplier)

	GameData.xp_global += total_xp
	MenuManager.show_message("XP gagnée : %d" % total_xp)

	for enemy in defeated_enemies:
		for entry in enemy.loot_table:
			var chance: float = clamp(entry.drop_chance * loot_multiplier, 0.0, 1.0)
			if randf() < chance:
				GameData.add_item(entry.item, entry.quantity)
				MenuManager.show_message("Objet obtenu : %s x%d" % [entry.item.item_name, entry.quantity])

	_end_combat()


func resolve_defeat() -> void:
	GameData.xp_global = 0
	MenuManager.show_message("Défaite... Retour à la prison.")

	_end_combat()

	TransitionManager.request_transition("res://donjon/prison/prison.tscn", "")


func _end_combat() -> void:
	for character in GameData.party:
		character.resync_attributes()

	pending_group = null
	pending_background = null
	pending_music = null
