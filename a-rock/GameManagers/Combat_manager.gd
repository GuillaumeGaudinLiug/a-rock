extends Node

const COMBAT_SCENE := preload("res://combats/CombatScene.tscn")
const COMBAT_TRANSITION_SCENE := preload("res://MainScenes/transitions/CombatTransitionScene.tscn")

var combat_instance: Node2D

var pending_group: EncounterEnemyGroup
var pending_background: Texture2D
var pending_music: AudioStream

var xp_multiplier: float = 1.0
var loot_multiplier: float = 1.0

var reveal_enemy_stats: bool = false


func start_encounter(group: EncounterEnemyGroup, background: Texture2D, music: AudioStream) -> void:
	pending_group = group
	pending_background = background
	pending_music = music
	xp_multiplier = 1.0
	loot_multiplier = 1.0
	reveal_enemy_stats = false
	# TODO : construire les CombatParticipant, puis pour chacun des joueurs :
	# participant.trigger_statuses(StatusEffect.TriggerType.ON_BATTLE_START, { "user": participant })

	GameManager.push_state(GameManager.GameState.COMBAT)
	# Lancement de la transition
	var transition: CanvasLayer = COMBAT_TRANSITION_SCENE.instantiate()
	transition.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(transition)

	await transition.play_intro()
	
	# Instancier la scene en combat entre les await
	# La scene de combat en bas de l'arborescence pour la priorité d'affichage
	combat_instance = COMBAT_SCENE.instantiate()
	combat_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(combat_instance)
	get_tree().root.move_child(combat_instance, get_tree().root.get_child_count() - 1)

	await transition.play_outro()
	transition.queue_free()



func resolve_victory(defeated_enemies: Array[EnemyData]) -> void:
	var total_xp := 0
	# TODO : construire les CombatParticipant, puis pour chacun des joueurs :
	# participant.trigger_statuses(StatusEffect.TriggerType.ON_BATTLE_END, { "user": participant })

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

	if combat_instance != null:
		combat_instance.queue_free()
		combat_instance = null

	var exploration_camera := get_tree().get_first_node_in_group("main_camera")
	if exploration_camera != null:
		exploration_camera.make_current()

	pending_group = null
	pending_background = null
	pending_music = null

	GameManager.pop_state()
