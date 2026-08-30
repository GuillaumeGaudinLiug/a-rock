extends CombatSceneAnimator

@export var ENEMY_FRONT_X := 0.0
@export var  ENEMY_BACK_X := -50.0
@export var  PLAYER_FRONT_X := 100.0
@export var  PLAYER_BACK_X := 120.0
@export var  PLAYER_ROW_SPACING_Y := 55.0
@export var  ENEMY_ROW_SPACING_Y := 80.0
@export var  OFFSET_Y := 0.0


const DAMAGE_POPUP_SCENE := preload("res://combats/elements/DamagePopup.tscn")
const TARGET_VIEW_SCENE := preload("res://combats/elements/CombatTargetView.tscn")

var popup_queue: Array[Dictionary] = []
var is_processing_popups := false

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


@onready var combat_camera: Camera2D = $CombatCamera


func _ready() -> void:
	combat_camera.position = Vector2(60, 50)  # ajuste le Y selon le nombre de lignes (ROW_SPACING_Y * nb participants / 2)
	combat_camera.zoom = Vector2(3, 3) 
	combat_camera.make_current()
	#Ouverture du bus de signal des effets pour alimenter les damagePopup
	EffectSignalBus.effect_applied.connect(_on_effect_applied)

	background.texture = CombatManager.pending_background
	MusicManager.play_music(CombatManager.pending_music)

	_build_participants()
	turn_manager.setup(all_participants)

	_apply_passive_skills()

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
	_layout_enemies()
	_layout_players()

func _layout_enemies() -> void:
	var front_row: Array[CombatParticipant] = enemy_participants.filter(func(p): return p.row == CharacterInstance.PartyRow.FRONT)
	var back_row: Array[CombatParticipant] = enemy_participants.filter(func(p): return p.row == CharacterInstance.PartyRow.BACK)

	for i in front_row.size():
		var p := front_row[i]
		p.world_position = Vector2(ENEMY_FRONT_X, 0 + i * ENEMY_ROW_SPACING_Y)
		_spawn_view(p, enemy_sprites)

	for i in back_row.size():
		var p := back_row[i]
		p.world_position = Vector2(ENEMY_BACK_X, 0 + i * ENEMY_ROW_SPACING_Y)
		_spawn_view(p, enemy_sprites)

func _layout_players() -> void:
	for i in player_participants.size():
		var p := player_participants[i]
		var x := PLAYER_BACK_X if p.row == CharacterInstance.PartyRow.BACK else PLAYER_FRONT_X
		p.world_position = Vector2(x, 0 + i * PLAYER_ROW_SPACING_Y)
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

		# VErifier que le participant est alive après les effets de debut de combat
		if not actor.is_alive():
			continue

		var action: CombatAction
		if actor.is_player:
			action = await _get_player_action(actor)
		else:
			action = actor.behavior.choose_action(actor, enemy_participants, player_participants)

		if action != null:
			# Numéro de tour
			actor.turn_count += 1
			_play_action_animation(actor, action)
			action.execute()
			
			var vfx_frames: SpriteFrames = null
			if action.type == CombatAction.ActionType.SKILL and action.skill != null:
				vfx_frames = action.skill.target_vfx
			elif action.type == CombatAction.ActionType.ITEM and action.item != null:
				vfx_frames = action.item.target_vfx

			if vfx_frames != null:
				for target in action.targets:
					_play_impact_vfx(target, vfx_frames)
			
			
			# EN cas de changement de row
			if action.type == CombatAction.ActionType.CHANGE_ROW:
				_reposition_participant(actor)

			await get_tree().create_timer(1).timeout

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

	
# Deplacer le CombatTargetView sur la row
func _reposition_participant(p: CombatParticipant) -> void:
	if p in enemy_participants:
		var same_row := enemy_participants.filter(func(other): return other.row == p.row)
		var index := same_row.find(p)
		var x := ENEMY_BACK_X if p.row == CharacterInstance.PartyRow.BACK else ENEMY_FRONT_X
		p.world_position = Vector2(x, 35 + index * ENEMY_ROW_SPACING_Y)
	else:
		var index := player_participants.find(p)
		var x := PLAYER_BACK_X if p.row == CharacterInstance.PartyRow.BACK else PLAYER_FRONT_X
		p.world_position = Vector2(x, 0 + index * PLAYER_ROW_SPACING_Y)

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
		EffectResult.Kind.DAMAGE_SP:
			color = Color.DARK_TURQUOISE
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
	if view != null and result.hit and (result.kind == EffectResult.Kind.DAMAGE or result.kind == EffectResult.Kind.DAMAGE_SP):
		_flash_hit(view.sprite)



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
	


func _exit_tree() -> void:
	if EffectSignalBus.effect_applied.is_connected(_on_effect_applied):
		EffectSignalBus.effect_applied.disconnect(_on_effect_applied)


func _on_effect_applied(target, result: EffectResult) -> void:
	if target is CombatParticipant and view_by_participant.has(target):
		popup_queue.append({ "target": target, "result": result })
		if not is_processing_popups:
			_process_popup_queue()

		if result.hit and result.kind == EffectResult.Kind.DAMAGE:
			_play_damage_animation(target)
			
			
func _apply_passive_skills() -> void:
	for p in player_participants:
		for skill in p.source_character.available_skills:
			if not skill.is_passive:
				continue
			for effect in skill.effects:
				effect.execute({ "actor": p, "target": p })



func _process_popup_queue() -> void:
	is_processing_popups = true

	while not popup_queue.is_empty():
		# Delai avant d'afficher la popup afin que l'animation se lance avant que les résultats apparaissent
		await get_tree().create_timer(0.4).timeout
		var entry: Dictionary = popup_queue.pop_front()
		_show_damage_popup(entry["target"], entry["result"])
		_refresh_participant_view(entry["target"])
		await get_tree().create_timer(0.1).timeout

	is_processing_popups = false
