# encounter_group.gd
class_name EncounterEnemyGroup
extends Resource

@export var group_name: String = ""
@export var members: Array[EncounterMember] = []
@export var weight: int = 1
