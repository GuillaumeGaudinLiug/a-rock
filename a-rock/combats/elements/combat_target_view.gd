class_name CombatTargetView
extends Node2D

signal target_clicked(participant: CombatParticipant)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var click_area: Area2D = $ClickArea
@onready var highlight: Sprite2D = $Highlight
@onready var status_icons: HBoxContainer = $StatusIcons
@onready var stat_bars: VBoxContainer = $StatBars
@onready var ep_bar: ProgressBar = $StatBars/EpBar
@onready var sp_bar: ProgressBar = $StatBars/SpBar
@onready var enemy_stat_bars: VBoxContainer = $EnemyStatsBar
@onready var enemy_ep_bar: ProgressBar = $EnemyStatsBar/EnemyEpBar
@onready var enemy_sp_bar: ProgressBar = $EnemyStatsBar/EnemySpBar
@onready var active_turn_indicator: Sprite2D = $ActiveTurnIndicator

var participant: CombatParticipant


func _ready() -> void:
	click_area.input_event.connect(_on_input_event)
	set_targetable(false)
	set_active_turn(false)


func setup(p: CombatParticipant) -> void:
	participant = p

	stat_bars.visible = p.is_player
	# TODO: enemy bars visible with passive skill
	if p.is_player:
		ep_bar.max_value = p.max_ep
		sp_bar.max_value = p.max_sp
		refresh_stat_bars()
	if not p.is_player:
		enemy_ep_bar.max_value = p.max_ep
		enemy_sp_bar.max_value = p.max_sp
		refresh_stat_bars()
	refresh_status_icons()


func set_targetable(is_targetable: bool) -> void:
	click_area.input_pickable = is_targetable
	highlight.visible = is_targetable


func refresh_stat_bars() -> void:
	if participant == null or not participant.is_player:
		return
	ep_bar.value = participant.current_ep
	sp_bar.value = participant.current_sp
	enemy_ep_bar.value = participant.current_ep
	enemy_sp_bar.value = participant.current_sp


func refresh_status_icons() -> void:
	for child in status_icons.get_children():
		child.free()

	if participant == null:
		return

	for instance in participant.active_statuses:
		if instance.status.icon == null:
			continue
		var icon_rect := TextureRect.new()
		icon_rect.texture = instance.status.icon
		icon_rect.custom_minimum_size = Vector2(16, 16)
		status_icons.add_child(icon_rect)


func _on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		target_clicked.emit(participant)


func set_active_turn(is_active: bool) -> void:
	active_turn_indicator.visible = is_active

func set_defeated() -> void:
	set_targetable(false)
	set_active_turn(false)

	for child in status_icons.get_children():
		child.free()

	if participant.is_player:
		# Reste visible, juste grisé pour indiquer l'état KO
		sprite.modulate = Color(0.681, 0.681, 0.681, 1.0)
	else:
		# Disparaît complètement de l'écran
		stat_bars.visible = false
		var tween := create_tween()
		tween.tween_property(sprite, "modulate", Color(0.341, 0.0, 0.0, 1.0), 0.4)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
		tween.tween_callback(func(): visible = false)
