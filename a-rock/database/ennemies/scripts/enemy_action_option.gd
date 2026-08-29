# enemy_action_option.gd
class_name EnemyActionOption
extends Resource

enum TargetStrategy { RANDOM, LOWEST_EP_PERCENT, HIGHEST_EP_PERCENT, SELF }

@export var skill: Skill
@export var weight: int = 1
@export var condition: BehaviorCondition
@export var target_strategy: TargetStrategy = TargetStrategy.RANDOM


func is_eligible(self_p: CombatParticipant, allies: Array[CombatParticipant], enemies: Array[CombatParticipant]) -> bool:
	if condition == null:
		return true
	return condition.can_use(self_p, allies, enemies)
