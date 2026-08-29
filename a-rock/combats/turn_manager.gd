# turn_manager.gd
class_name TurnManager
extends RefCounted

const GAUGE_THRESHOLD := 200.0

var participants: Array[CombatParticipant] = []


func setup(all_participants: Array[CombatParticipant]) -> void:
	participants = all_participants
	for p in participants:
		p.gauge = randf() * GAUGE_THRESHOLD * 0.5  # léger décalage initial pour éviter un ordre identique à chaque combat


func get_next_actor() -> CombatParticipant:
	var alive := participants.filter(func(p): return p.is_alive())
	if alive.is_empty():
		return null
		
	var loop_turn : bool = true
	var return_participant
	while loop_turn:
		for p in alive:
			# Calcul de la jaude d'action des participants
			var roll_factor := 1.0 + randf_range(-0.5, 0.5)
			p.gauge += 1 + (p.adaptability/3 * roll_factor)

			if p.gauge >= GAUGE_THRESHOLD:
				p.gauge -= GAUGE_THRESHOLD
				return_participant = p
				loop_turn = false
	
	return return_participant
