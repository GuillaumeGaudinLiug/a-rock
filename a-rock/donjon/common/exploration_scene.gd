extends Node2D

@export var scene_name : String
@export var spawn_points: Node2D
@export var encounter_table: EncounterTable
@export_range(0.0, 1.0, 0.01) var encounter_chance_per_step: float = 0.05
@export var min_steps_between_encounters: int = 3
@export var music: AudioStream

const STEP_DISTANCE := 16.0

var player: Node2D
var last_player_position: Vector2
var distance_accumulator: float = 0.0
var steps_since_last_encounter: int = 999


func _ready() -> void:
	_handle_spawn()
	MusicManager.play_music(music)

	player = get_tree().get_first_node_in_group("player")
	if player != null:
		last_player_position = player.global_position


func _handle_spawn() -> void:
	if TransitionManager.pending_spawn_name == "":
		return

	var spawn := spawn_points.get_node_or_null(TransitionManager.pending_spawn_name)
	if spawn == null:
		push_warning("Spawn point '%s' introuvable dans cette scène." % TransitionManager.pending_spawn_name)
		TransitionManager.pending_spawn_name = ""
		return

	var p := get_tree().get_first_node_in_group("player")
	if p != null:
		p.global_position = spawn.global_position

	TransitionManager.pending_spawn_name = ""


func _process(_delta: float) -> void:
	if player == null or encounter_table == null:
		return
	if not GameManager.is_state(GameManager.GameState.EXPLORATION):
		return

	var moved := player.global_position.distance_to(last_player_position)
	last_player_position = player.global_position
	distance_accumulator += moved

	while distance_accumulator >= STEP_DISTANCE:
		distance_accumulator -= STEP_DISTANCE
		_on_step_taken()


func _on_step_taken() -> void:
	steps_since_last_encounter += 1

	if steps_since_last_encounter < min_steps_between_encounters:
		return

	if randf() < encounter_chance_per_step:
		var group := encounter_table.roll_group()
		if group != null:
			_trigger_encounter(group)


func _trigger_encounter(group: EncounterEnnemyGroup) -> void:
	steps_since_last_encounter = 0
	print("Rencontre déclenchée : ", group.group_name)
	# TODO : brancher sur le vrai système de combat une fois construit
