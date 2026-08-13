# effect_xp_bonus.gd
class_name EffectXpBonus
extends AbstractEffect

@export_range(0.0, 2.0, 0.01) var bonus_percent: float = 0.5

func _execute(context: Dictionary) -> void:
	CombatSetup.xp_multiplier += bonus_percent
