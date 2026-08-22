# target_scope.gd
class_name TargetScope
extends RefCounted

enum Type { SINGLE_ENEMY, SINGLE_ALLY, ANY_SINGLE, ALL_ENEMIES, ALL_ALLIES, SELF, ALL }


static func get_valid_targets(scope: Type, actor: CombatParticipant, allies: Array[CombatParticipant], enemies: Array[CombatParticipant]) -> Array[CombatParticipant]:
	match scope:
		Type.SINGLE_ENEMY, Type.ALL_ENEMIES:
			return enemies.filter(func(p): return p.is_alive())
		Type.SINGLE_ALLY, Type.ALL_ALLIES:
			return allies.filter(func(p): return p.is_alive())
		Type.ANY_SINGLE:
			return (allies + enemies).filter(func(p): return p.is_alive())
		Type.SELF:
			return [actor]
		Type.ALL:
			var alliesParticipant : Array[CombatParticipant] = allies.filter(func(p): return p.is_alive())
			var ennemiesParticipant : Array[CombatParticipant] = enemies.filter(func(p): return p.is_alive())
			alliesParticipant.append_array(ennemiesParticipant)
			return alliesParticipant
		_:
			return []


static func is_multi_target(scope: Type) -> bool:
	return scope == Type.ALL_ENEMIES or scope == Type.ALL_ALLIES or scope == Type.ALL
