extends Node

signal state_changed(old_state: GameState, new_state: GameState)

enum GameState { EXPLORATION, COMBAT, MENU, CUTSCENE, TITLESCREEN }

var current_state: GameState = GameState.EXPLORATION
var _state_stack: Array[GameState] = []


func change_state(new_state: GameState) -> void:
	if new_state == current_state:
		return
	var old_state := current_state
	current_state = new_state
	_apply_pause(new_state)
	state_changed.emit(old_state, new_state)


func push_state(new_state: GameState) -> void:
	_state_stack.push_back(current_state)
	change_state(new_state)


func pop_state() -> void:
	if _state_stack.is_empty():
		push_warning("GameManager: pop_state appelé alors que la pile est vide.")
		return
	change_state(_state_stack.pop_back())


func _apply_pause(state: GameState) -> void:
	get_tree().paused = (state == GameState.MENU)


func is_state(state: GameState) -> bool:
	return current_state == state
