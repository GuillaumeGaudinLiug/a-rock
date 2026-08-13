class_name EffectApplyStatus
extends AbstractEffect

@export var status: StatusEffect


func _execute(context: Dictionary) -> void:
	var actor = context.get("actor")
	var target = context.get("target")
	if actor == null or target == null or status == null:
		return

	if not _resolve_apply_chance(actor, target):
		print("%s résiste à %s" % [target.display_name, status.status_name])
		return

	var duration := _roll_duration(actor)
	target.apply_status(status, duration)


func _resolve_apply_chance(actor, target) -> bool:
	var actor_value: float = actor.get_stat(status.apply_chance_stat)
	var target_value: float = target.get_stat(status.resist_chance_stat)
	
	# TODO: vrai calcul de la chance d'application du statut
	var chance = 1.0
	#var chance: float = status.base_apply_chance + (actor_value - target_value) * status.chance_stat_influence
	chance = clamp(chance, 0.05, 0.95)

	return randf() < chance


func _roll_duration(actor) -> int:
	# TODO: vraie formule de duration
	var actor_value: float = actor.get_stat(status.duration_stat)
	var bonus_turns := int(actor_value * status.duration_stat_influence)

	var base_duration := randi_range(status.min_duration_turns, status.max_duration_turns)
	return base_duration + bonus_turns
