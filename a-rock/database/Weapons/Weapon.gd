# weapon.gd
class_name Weapon
extends Resource

@export var weapon_name: String = ""
@export var icon: Texture2D
@export var max_level: int = 6

@export var level_bonuses: Array[WeaponLevelStats] = []  # index 0 = niveau 1, index 9 = niveau 10
@export_group("Compétences d'arme")
@export var level_unlocks: Array[LevelUnlock] = []

func get_stat_bonus(stat_name: String, weapon_level: int) -> int:
	if weapon_level <= 0:
		return 0  # arme jamais obtenue : aucun bonus, ce n'est pas une erreur
	var index := weapon_level - 1
	if index < 0 or index >= level_bonuses.size():
		push_warning("Weapon '%s': pas de bonus défini pour le niveau %d." % [weapon_name, weapon_level])
		return 0
	return level_bonuses[index].get_stat(stat_name)

# 
func get_xp_required(weapon_level: int) -> int:
	var index := weapon_level - 1
	if index < 0 or index >= level_bonuses.size():
		push_warning("Weapon '%s': pas de coût XP défini pour le niveau %d." % [weapon_name, weapon_level])
		return -1
	return level_bonuses[index].xp_required
	
	
func get_skills_by_level(weapon_level: int) -> Array[Skill]:
	var result: Array[Skill] = []
	for unlock in level_unlocks:
		if unlock.level <= weapon_level:
			result.append_array(unlock.skills)
	return result
