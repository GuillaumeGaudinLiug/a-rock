extends Node

var pending_group: EncounterEnemyGroup
var pending_background: Texture2D
var pending_music: AudioStream


func start_encounter(group: EncounterEnemyGroup, background: Texture2D, music: AudioStream) -> void:
	pending_group = group
	pending_background = background
	pending_music = music
	print("Combat préparé : ", group.group_name, " (", group.members.size(), " ennemis)")
	# TODO : une fois le système de combat construit, déclencher ici la vraie transition
	# GameManager.push_state(GameManager.GameState.COMBAT)


func resolve_victory(defeated_enemies: Array[EnemyData]) -> void:
	var total_xp := 0
	for enemy in defeated_enemies:
		total_xp += enemy.xp_value

	GameData.xp_global += total_xp
	MenuManager.show_message("XP gagnée : %d" % total_xp)

	for enemy in defeated_enemies:
		for entry in enemy.loot_table:
			if randf() < entry.drop_chance:
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
