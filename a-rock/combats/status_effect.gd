# status_effect.gd
class_name StatusEffect
extends Resource

enum DurationType { TURNS, PERMANENT }
enum TriggerType { NONE, ON_BATTLE_START, ON_BATTLE_END, ON_TURN_START, ON_TURN_END, ON_HIT_TAKEN, ON_HIT_DEALT }
@export var status_name: String = ""
@export var visible_in_battle: bool = false
@export var icon: Texture2D

@export var duration_type: DurationType = DurationType.TURNS
@export var duration_turns: int = 3

@export var stat_modifiers: Array[StatModifier] = []       # buffs/debuffs continus (ex: -20% Courage)
@export var trigger: TriggerType = TriggerType.NONE        # déclenche trigger_effects à ce moment précis
@export var trigger_effects: Array[AbstractEffect] = []    # ex: poison -> dégâts à ON_TURN_START



# ajouts dans status_effect.gd
@export_group("Application (si non permanent)")
@export_range(0.0, 1.0, 0.01) var base_apply_chance: float = 0.7
@export var apply_chance_stat: String = "passion"   # côté attaquant : augmente la chance
@export var resist_chance_stat: String = "spirit"    # côté cible : diminue la chance
@export_range(0.0, 0.1, 0.001) var chance_stat_influence: float = 0.02

@export var min_duration_turns: int = 2
@export var max_duration_turns: int = 4
@export var duration_stat: String = "passion"        # côté attaquant : influence la durée tirée
@export_range(0.0, 0.1, 0.001) var duration_stat_influence: float = 0.05
