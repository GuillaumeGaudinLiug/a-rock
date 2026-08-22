# enemy_behavior.gd
class_name EnemyBehavior
extends Resource

@export var double_turn: bool = false

# TODO à enrichir
# À redéfinir : retourne l'action choisie par l'ennemi pour ce tour
func choose_action(self_participant: CombatParticipant, allies: Array[CombatParticipant], enemies: Array[CombatParticipant]) -> CombatAction:
	push_warning("choose_action() non implémenté pour : %s" % get_class())
	return CombatAction.new()
