class_name EffectRevealEnemyStats
extends AbstractEffect

func _execute(context: Dictionary, result: EffectResult) -> void:
	CombatManager.reveal_enemy_stats = true
	result.kind = EffectResult.Kind.INFO
	result.value_label = "Vision tactique activée"
