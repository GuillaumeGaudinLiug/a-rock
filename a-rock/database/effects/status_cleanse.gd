class_name EffectCleanse
extends AbstractEffect

func _execute(context: Dictionary, result: EffectResult) -> void:
	var target = context.get("target")
	if target == null:
		return

	var removed : int = target.remove_cancellable_statuses()

	result.kind = EffectResult.Kind.INFO
	if removed > 0:
		result.value_label = "Statuts soignés (%d)" % removed
	else:
		result.value_label = "Aucun statut à retirer"
