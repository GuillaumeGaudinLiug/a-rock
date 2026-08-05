# weapon.gd
class_name Weapon
extends Resource

@export var weapon_name: String = ""
@export var icon: SpriteFrames
@export var max_level: int = 6

@export var level_bonuses: Array[WeaponLevelStats] = []  # index 0 = niveau 1, index 9 = niveau 10


func get_stat_bonus(stat_name: String, weapon_level: int) -> int:
	var index := weapon_level - 1
	if index < 0 or index >= level_bonuses.size():
		push_warning("Weapon '%s': pas de bonus défini pour le niveau %d." % [weapon_name, weapon_level])
		return 0
	return level_bonuses[index].get_stat(stat_name)


# TODO: SKILLS
