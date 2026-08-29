class_name EnemyBehavior
extends Resource

@export var turn_patterns: Array[EnemyTurnPattern] = []
@export var double_turn: bool = false


func choose_action(self_p: CombatParticipant, allies: Array[CombatParticipant], enemies: Array[CombatParticipant]) -> CombatAction:
	if turn_patterns.is_empty():
		return null

	var turn_index := self_p.turn_count % turn_patterns.size()
	var pattern := turn_patterns[turn_index]

	var eligible := pattern.options.filter(func(o): return o.is_eligible(self_p, allies, enemies))
	if eligible.is_empty():
		return null

	var chosen := _weighted_pick(eligible)
	var targets := _select_targets(chosen, self_p, allies, enemies)
	if targets.is_empty():
		return null

	var action := CombatAction.new()
	action.type = CombatAction.ActionType.SKILL
	action.user = self_p
	action.targets = targets
	action.effects = chosen.skill.effects
	action.skill = chosen.skill
	return action


func _weighted_pick(eligible: Array) -> EnemyActionOption:
	var total := 0
	for o in eligible:
		total += o.weight
	var roll := randi() % total
	var cumulative := 0
	for o in eligible:
		cumulative += o.weight
		if roll < cumulative:
			return o
	return eligible[-1]


func _select_targets(option: EnemyActionOption, self_p: CombatParticipant, allies: Array[CombatParticipant], enemies: Array[CombatParticipant]) -> Array[CombatParticipant]:
	var pool := TargetScope.get_valid_targets(option.skill.target_scope, self_p, allies, enemies)
	if pool.is_empty():
		return []

	if TargetScope.is_multi_target(option.skill.target_scope):
		return pool

	match option.target_strategy:
		EnemyActionOption.TargetStrategy.SELF:
			return [self_p]
		EnemyActionOption.TargetStrategy.LOWEST_EP_PERCENT:
			pool.sort_custom(func(a, b): return (float(a.current_ep)/a.max_ep) < (float(b.current_ep)/b.max_ep))
			return [pool[0]]
		EnemyActionOption.TargetStrategy.HIGHEST_EP_PERCENT:
			pool.sort_custom(func(a, b): return (float(a.current_ep)/a.max_ep) > (float(b.current_ep)/b.max_ep))
			return [pool[0]]
		_:
			return [pool[randi() % pool.size()]]
