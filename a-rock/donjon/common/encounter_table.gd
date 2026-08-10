# encounter_table.gd
class_name EncounterTable
extends Resource

@export var entries: Array[EncounterEntry] = []
@export_range(0.0, 1.0, 0.01) var encounter_chance_per_step: float = 0.05
@export var min_steps_between_encounters: int = 3


func roll_group() -> EncounterEnnemyGroup:
	if entries.is_empty():
		return null

	var total_weight := 0
	for entry in entries:
		total_weight += entry.weight

	var roll := randi() % total_weight
	var cumulative := 0
	for entry in entries:
		cumulative += entry.weight
		if roll < cumulative:
			return entry.group

	return entries[-1].group
