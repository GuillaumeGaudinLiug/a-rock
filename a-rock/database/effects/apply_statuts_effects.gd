class_name EffectApplyStatus
extends AbstractEffect

@export var status: StatusEffect


func _execute(context: Dictionary, result: EffectResult) -> void:
	var actor = context.get("user")
	var target = context.get("target")
	
	if actor == null or target == null or status == null:
		print("Missing effect status requirement")
		return 

	if not _resolve_apply_chance(actor, target):
		print("%s résiste à %s" % [target.display_name, status.status_name])
		result.hit = false
		result.kind = EffectResult.Kind.STATUS_RESISTED
		result.status = status
		return

	print("Status Applied: %s " % [status.status_name] )
	var duration := _roll_duration(actor)
	result.kind = EffectResult.Kind.STATUS_APPLIED
	result.status = status
	target.apply_status(status, duration)
	result.hit = true	
	return 


func _resolve_apply_chance(actor, target) -> bool:
	var actor_value: float = actor.get_stat(status.apply_chance_stat)
	var target_value: float = target.get_stat(status.resist_chance_stat)
	
	# TODO: vrai calcul de la chance d'application du statut
	var chance = max (1.0, 1.0)
	#var chance: float = status.base_apply_chance + (actor_value - target_value) * status.chance_stat_influence
	#chance = clamp(chance, 0.05, 0.1)
	var applied = randf() < chance
	return randf() < chance


func _roll_duration(actor) -> int:
	# TODO: vraie formule de duration
	var actor_value: float = actor.get_stat(status.duration_stat)
	var bonus_turns := int(actor_value * status.duration_stat_influence)

	var base_duration := randi_range(status.min_duration_turns, status.max_duration_turns)
	return base_duration + bonus_turns
