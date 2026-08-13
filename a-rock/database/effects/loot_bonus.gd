# effect_loot_bonus.gd
class_name EffectLootBonus
extends AbstractEffect

@export_range(0.0, 2.0, 0.01) var bonus_percent: float = 0.3

func _execute(context: Dictionary) -> void:
	CombatSetup.loot_multiplier += bonus_percent
