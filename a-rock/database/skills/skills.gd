# skill.gd
class_name Skill
extends Resource

@export var skill_name: String = ""
@export var description: String = ""
@export var icon: Texture2D

@export_flags("Exploration", "Combat", "Menu") var usable_contexts: int = 2
@export var effect: AbstractEffect

@export_group("Coût")
@export var ep_cost: int = 0
@export_range(0.0, 1.0, 0.01) var ep_cost_percent: float = 0.0
@export var sp_cost: int = 0
@export_range(0.0, 1.0, 0.01) var sp_cost_percent: float = 0.0


func get_ep_cost(character: CharacterInstance) -> int:
	return ep_cost + int(character.max_ep * ep_cost_percent)


func get_sp_cost(character: CharacterInstance) -> int:
	return sp_cost + int(character.max_sp * sp_cost_percent)


func is_usable_in(state: GameManager.GameState) -> bool:
	match state:
		GameManager.GameState.EXPLORATION: return usable_contexts & 1 != 0
		GameManager.GameState.COMBAT: return usable_contexts & 2 != 0
		GameManager.GameState.MENU: return usable_contexts & 4 != 0
		_: return false
