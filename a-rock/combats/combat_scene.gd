extends Node2D

@export var ENEMY_FRONT_X := 0.0
@export var  ENEMY_BACK_X := -50.0
@export var  PLAYER_FRONT_X := 100.0
@export var  PLAYER_BACK_X := 120.0
@export var  ROW_SPACING_Y := 50.0
@export var  OFFSET_Y := 0.0


const DAMAGE_POPUP_SCENE := preload("res://combats/elements/DamagePopup.tscn")
const TARGET_VIEW_SCENE := preload("res://combats/elements/CombatTargetView.tscn")


@onready var background: Sprite2D = $Background
@onready var enemy_sprites: Node2D = $EnemySprites
@onready var player_sprites: Node2D = $PlayerSprites
@onready var popup_layer: Node2D = $PopupLayer
@onready var enemy_names_list: VBoxContainer = $BottomUI/EnemyNamesList
@onready var action_menu: Control = $BottomUI/ActionMenu

var turn_manager := TurnManager.new()
var all_participants: Array[CombatParticipant] = []
var enemy_participants: Array[CombatParticipant] = []
var player_participants: Array[CombatParticipant] = []

var view_by_participant: Dictionary = {}  # CombatParticipant -> CombatTargetView


@onready var combat_camera: Camera2D = $CombatCamera


func _ready() -> void:
	combat_camera.position = Vector2(60, 50)  # ajuste le Y selon le nombre de lignes (ROW_SPACING_Y * nb participants / 2)
	combat_camera.zoom = Vector2(3, 3) 
	combat_camera.make_current()

	background.texture = CombatManager.pending_background
	MusicManager.play_music(CombatManager.pending_music)

	_build_participants()
	turn_manager.setup(all_participants)

	for p in player_participants:
		p.trigger_statuses(StatusEffect.TriggerType.ON_BATTLE_START, { "actor": p, "target": p })
		_refresh_participant_view(p)

	_run_combat_loop()


func _build_participants() -> void:
	for character in GameData.party:
		var p := CombatParticipant.from_character(character)
		player_participants.append(p)
		all_participants.append(p)

	for member in CombatManager.pending_group.members:
		var p := CombatParticipant.from_enemy(member)
		enemy_participants.append(p)
		all_participants.append(p)

	_layout_and_spawn_views()
	_populate_enemy_names()


func _layout_and_spawn_views() -> void:
	for i in enemy_participants.size():
		var p := enemy_participants[i]
		var x := ENEMY_BACK_X if p.row == CharacterInstance.PartyRow.BACK else ENEMY_FRONT_X
		p.world_position = Vector2(x, OFFSET_Y + i * ROW_SPACING_Y)
		_spawn_view(p, enemy_sprites)

	for i in player_participants.size():
		var p := player_participants[i]
		var x := PLAYER_BACK_X if p.row == CharacterInstance.PartyRow.BACK else PLAYER_FRONT_X
		p.world_position = Vector2(x, OFFSET_Y + i * ROW_SPACING_Y)
		_spawn_view(p, player_sprites)


func _spawn_view(p: CombatParticipant, parent: Node2D) -> void:
	var view: CombatTargetView = TARGET_VIEW_SCENE.instantiate()
	view.position = p.world_position
	parent.add_child(view)
	view.setup(p)

	var frames := p.get_idle_frames()
	view.sprite.sprite_frames = frames
	if frames != null and frames.has_animation("default"):
		view.sprite.play("default")

	view_by_participant[p] = view


func _populate_enemy_names() -> void:
	for child in enemy_names_list.get_children():
		child.free()
	for p in enemy_participants:
		var label := Label.new()
		label.text = p.display_name
		enemy_names_list.add_child(label)

# Loop de combat
func _run_combat_loop() -> void:
	while true:
		if enemy_participants.all(func(p): return not p.is_alive()):
			_on_victory()
			return
		if player_participants.all(func(p): return not p.is_alive()):
			_on_defeat()
			return

		var actor := turn_manager.get_next_actor()
		if actor == null:
			await get_tree().process_frame
			continue
		# Afficher l'icone du tour actif
		var view: CombatTargetView = view_by_participant.get(actor)
		if view != null:
			view.set_active_turn(true)
		actor.trigger_statuses(StatusEffect.TriggerType.ON_TURN_START, { "actor": actor, "target": actor })
		_refresh_participant_view(actor)

		if not actor.is_alive():
			continue

		var action: CombatAction
		if actor.is_player:
			action = await _get_player_action(actor)
		else:
			action = actor.behavior.choose_action(actor, enemy_participants, player_participants)

		if action != null:
			_play_action_animation(actor, action)
			var results := action.execute()
			_show_results(action, results)
			# EN cas de changement de row
			if action.type == CombatAction.ActionType.CHANGE_ROW:
				_reposition_participant(actor)

			await get_tree().create_timer(0.4).timeout

		actor.trigger_statuses(StatusEffect.TriggerType.ON_TURN_END, { "actor": actor, "target": actor })
		actor.tick_turn_end()
		_refresh_participant_view(actor)

		# Retour à l'animation idle
		_reset_to_idle(actor)

		# Refermez l'icone du tour actif
		if view != null:
			view.set_active_turn(false)
		_refresh_dead_views()

		await get_tree().process_frame


func _get_player_action(actor: CombatParticipant) -> CombatAction:
	action_menu.show()
	action_menu.open_for(actor, player_participants, enemy_participants, self)
	var action: CombatAction = await action_menu.action_confirmed
	action_menu.hide()
	return action


func _play_action_animation(actor: CombatParticipant, action: CombatAction) -> void:
	var view: CombatTargetView = view_by_participant.get(actor)
	if view == null:
		return
	
	# Lancer le frame specific du skill
	if action.type == CombatAction.ActionType.SKILL and action.skill != null:
		var frames := action.skill.get_animation_frames(actor.get_animation_set())
		view.sprite.sprite_frames = frames
		if frames != null and frames.has_animation("default"):
			view.sprite.play("default")
		return
	# TODO: Lancement de l'animation de combat par defaut
	var frames := actor.get_animation_set().get_frames(CombatAnimationSet.State.COMBAT)
	view.sprite.sprite_frames = frames
	if frames != null and frames.has_animation("default"):
		view.sprite.play("default")


func _show_results(action: CombatAction, results: Array[EffectResult]) -> void:
	for i in results.size():
		var result := results[i]
		var target_index := i % action.targets.size()
		var target := action.targets[target_index]
		_show_damage_popup(target, result)
		_refresh_participant_view(target)
		# Petit temps entre les popup
		await get_tree().create_timer(0.25).timeout

# Deplacer le CombatTargetView sur la row
func _reposition_participant(p: CombatParticipant) -> void:
	var is_enemy := p in enemy_participants
	var list := enemy_participants if is_enemy else player_participants
	var index := list.find(p)

	var x: float
	if is_enemy:
		x = ENEMY_BACK_X if p.row == CharacterInstance.PartyRow.BACK else ENEMY_FRONT_X
	else:
		x = PLAYER_BACK_X if p.row == CharacterInstance.PartyRow.BACK else PLAYER_FRONT_X

	p.world_position = Vector2(x, OFFSET_Y + index * ROW_SPACING_Y)

	var view: CombatTargetView = view_by_participant.get(p)
	if view != null:
		var tween := create_tween()
		tween.tween_property(view, "position", p.world_position, 0.3)
		

func _show_damage_popup(target: CombatParticipant, result: EffectResult) -> void:
	var popup: Node2D = DAMAGE_POPUP_SCENE.instantiate()
	popup_layer.add_child(popup)
	popup.global_position = target.world_position

	var color := Color.WHITE
	var icon: Texture2D = null

	match result.kind:
		EffectResult.Kind.DAMAGE:
			color = Color.RED
		EffectResult.Kind.HEAL:
			color = Color.GREEN
		EffectResult.Kind.STATUS_APPLIED:
			color = Color.PURPLE
			icon = result.status.icon
		EffectResult.Kind.STATUS_RESISTED:
			color = Color.GRAY
			icon = result.status.icon
		EffectResult.Kind.MISS:
			color = Color.GRAY
	
	# TODO: Setup différent en fonction du type d'effet
	print(JSON.stringify(inst_to_dict(result), "\t"))
	popup.setup(str(result.value), color, icon)
	popup.play()

	var view: CombatTargetView = view_by_participant.get(target)
	if view != null and result.hit and result.kind == EffectResult.Kind.DAMAGE:
		_flash_hit(view.sprite)


func _flash_hit(sprite: AnimatedSprite2D) -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)

# Retour à l'animation idle
func _reset_to_idle(p: CombatParticipant) -> void:
	var view: CombatTargetView = view_by_participant.get(p)
	if view == null or not p.is_alive():
		return  # un participant KO garde son animation KO, pas l'idle

	var frames := p.get_idle_frames()
	view.sprite.sprite_frames = frames
	if frames != null and frames.has_animation("default"):
		view.sprite.play("default")

func _refresh_participant_view(p: CombatParticipant) -> void:
	var view: CombatTargetView = view_by_participant.get(p)
	if view != null:
		view.refresh_status_icons()
		view.refresh_stat_bars()


# Affichage du cas particuliers de la mort
func _refresh_dead_views() -> void:
	for p in all_participants:
		if not p.is_alive():
			var view: CombatTargetView = view_by_participant.get(p)
			if view == null:
				continue

			if view.visible == false:
				continue  # déjà traité (ennemi déjà masqué), rien à refaire

			view.set_defeated()

			if p.is_player:
				var frames := p.get_animation_set().get_frames(CombatAnimationSet.State.KO)
				if frames != null:
					view.sprite.sprite_frames = frames
					if frames.has_animation("default"):
						view.sprite.play("default")
# Conserver les pertes d'ep et sp à la fin du combat
func _sync_participants_to_characters() -> void:
	for p in player_participants:
		if p.source_character != null:
			p.source_character.current_ep = min(p.current_ep, p.max_ep)
			p.source_character.current_sp = min(p.current_sp, p.max_sp)

# Declaration de victoire
func _on_victory() -> void:
	_sync_participants_to_characters()
	var defeated: Array[EnemyData] = []
	for p in enemy_participants:
		defeated.append(p.source_enemy)
	CombatManager.resolve_victory(defeated)


func _on_defeat() -> void:
	CombatManager.resolve_defeat()
	
