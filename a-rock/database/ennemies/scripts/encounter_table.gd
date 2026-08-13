class_name EncounterTable
extends Resource

@export var entries: Array[EncounterEnemyGroup] = []


func roll_group() -> EncounterEnemyGroup:
	if entries.is_empty():
		return null

	var total_weight := 0
	for entry in entries:
		total_weight += entry.weight

	if total_weight <= 0:
		return null

	var roll := randi() % total_weight
	var cumulative := 0
	for entry in entries:
		cumulative += entry.weight
		if roll < cumulative:
			return entry

	return entries[-1]
