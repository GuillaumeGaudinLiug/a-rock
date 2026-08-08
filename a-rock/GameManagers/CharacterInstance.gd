# character_instance.gd
class_name CharacterInstance
extends RefCounted

# Champs modifiables par opération de lvlup et sauvegardables
enum PartyRow { FRONT, BACK }

var class_level : int = 0
var character_name : String = ""
var character_class: CharacterClass 
var determination_lvl: int = 0
var courage_lvl: int = 0
var passion_lvl: int = 0
var spirit_lvl: int = 0
var adaptability_lvl: int = 0
var weapon_levels: Dictionary = {}  # ex: { "res://weapons/sword.tres": 3 }

# Stats courante 
var stats_lvl: int
var max_ep: int
var max_sp: int
var current_ep: int
var current_sp: int
var determination: int
var courage: int
var passion: int
var spirit:int
var adaptability: int
var equipped_weapon: Weapon
var available_skills: Array[Skill] = []  # calculé, jamais sauvegardé

var row: PartyRow = PartyRow.FRONT

var status: Array[String] # TODO : statuts effect



func _init() -> void:
	
	return


func resync_attributes() -> CharacterInstance:
	var cls: CharacterClass = character_class
	if cls == null:
		push_warning("CharacterInstance.resync_attributes: classe introuvable ('%s')." % character_class)
		return self

	# --- Base classe + points investis (stat_levels) ---
	determination = cls.base_determination + determination_lvl
	courage = cls.base_courage + courage_lvl
	passion = cls.base_passion + passion_lvl
	spirit = cls.base_spirit + spirit_lvl
	adaptability = cls.base_adaptability + adaptability_lvl

	max_ep = cls.base_max_ep
	max_ep += LvlConfig.ep_bonus_per_stat.get("determination", 0) * determination_lvl
	max_ep += LvlConfig.ep_bonus_per_stat.get("courage", 0) * courage_lvl
	max_ep += LvlConfig.ep_bonus_per_stat.get("passion", 0) * passion_lvl
	max_ep += LvlConfig.ep_bonus_per_stat.get("spirit", 0) * spirit_lvl
	max_ep += LvlConfig.ep_bonus_per_stat.get("adaptability", 0) * adaptability_lvl

	max_sp = cls.base_max_sp
	max_sp += LvlConfig.sp_bonus_per_stat.get("determination", 0) * determination_lvl
	max_sp += LvlConfig.sp_bonus_per_stat.get("courage", 0) * courage_lvl
	max_sp += LvlConfig.sp_bonus_per_stat.get("passion", 0) * passion_lvl
	max_sp += LvlConfig.sp_bonus_per_stat.get("spirit", 0) * spirit_lvl
	max_sp += LvlConfig.sp_bonus_per_stat.get("adaptability", 0) * adaptability_lvl

	# --- Bonus de l'arme équipée, selon son niveau actuel ---
	if equipped_weapon != null:
		var weapon_level: int = weapon_levels.get(equipped_weapon, 0)

		determination += equipped_weapon.get_stat_bonus("determination", weapon_level)
		courage += equipped_weapon.get_stat_bonus("courage", weapon_level)
		passion += equipped_weapon.get_stat_bonus("passion", weapon_level)
		spirit += equipped_weapon.get_stat_bonus("spirit", weapon_level)
		adaptability += equipped_weapon.get_stat_bonus("adaptability", weapon_level)
		max_ep += equipped_weapon.get_stat_bonus("max_ep", weapon_level)
		max_sp += equipped_weapon.get_stat_bonus("max_sp", weapon_level)

	# --- Compétences débloquées (classe + arme) ---
	available_skills = []
	if cls != null:
		available_skills.append_array(cls.get_skills_by_level(class_level))
	if equipped_weapon != null:
		var weapon_level: int = weapon_levels.get(equipped_weapon, 0)
		available_skills.append_array(equipped_weapon.get_skills_by_level(weapon_level))

	return self

func to_dict() -> Dictionary:
	var weapon_levels_serialized: Dictionary = {}
	for weapon in weapon_levels.keys():
		if weapon != null:
			weapon_levels_serialized[weapon.resource_path] = weapon_levels[weapon]

	return {
		"class_level": class_level,
		"character_name": character_name, 
		"character_class": character_class.resource_path if character_class != null else "",
		"equipped_weapon": equipped_weapon.resource_path if equipped_weapon != null else "",
		"weapon_levels": weapon_levels_serialized,
		"determination_lvl": determination_lvl,
		"courage_lvl": courage_lvl,
		"passion_lvl": passion_lvl,
		"spirit_lvl": spirit_lvl,
		"adaptability_lvl": adaptability_lvl,
		"row": row
	}


static func from_dict(data: Dictionary) -> CharacterInstance:
	var instance := CharacterInstance.new()
	instance.class_level = data["class_level"]
	instance.character_name = data["character_name"]
	instance.character_class = load(data["character_class"]) if data["character_class"] != "" else null
	instance.equipped_weapon = load(data["equipped_weapon"]) if data["equipped_weapon"] != "" else null

	instance.weapon_levels = {}
	for weapon_path in data["weapon_levels"].keys():
		var weapon: Weapon = load(weapon_path)
		instance.weapon_levels[weapon] = data["weapon_levels"][weapon_path]

	instance.determination_lvl = data["determination_lvl"]
	instance.courage_lvl = data["courage_lvl"]
	instance.passion_lvl = data["passion_lvl"]
	instance.spirit_lvl = data["spirit_lvl"]
	instance.adaptability_lvl = data["adaptability_lvl"]
	instance.row = data.get("row", PartyRow.FRONT)
	
	instance.resync_attributes()
	# Redonner max ep/sp à load
	instance.current_ep = instance.max_ep
	instance.current_sp = instance.max_sp
	
	return instance


# ajouts dans lvlup.gd

func try_level_up_weapon(weapon: Weapon) -> bool:
	if weapon == null:
		return false

	var current_level: int = weapon_levels.get(weapon, 1)
	if current_level >= weapon.max_level:
		push_warning("Weapon '%s' déjà au niveau maximum." % weapon.weapon_name)
		return false

	var next_level := current_level + 1
	var cost := weapon.get_xp_required(next_level)

	if cost < 0 or GameData.xp_global < cost:
		return false

	GameData.xp_global -= cost
	weapon_levels[weapon] = next_level

	resync_attributes()
	return true


func try_level_up_stat(stat_name: String) -> bool:
	if stat_name not in LvlConfig.INVESTABLE_STATS:
		push_warning("Stat '%s' non investissable." % stat_name)
		return false

	var total_levels := determination_lvl + courage_lvl + passion_lvl + spirit_lvl + adaptability_lvl
	var cost : int = LvlConfig.get_stat_level_cost(total_levels)

	if cost < 0 or GameData.xp_global < cost:
		return false

	GameData.xp_global -= cost

	match stat_name:
		"determination": determination_lvl += 1
		"courage": courage_lvl += 1
		"passion": passion_lvl += 1
		"spirit": spirit_lvl += 1
		"adaptability": adaptability_lvl += 1

	resync_attributes()
	return true


func try_level_up_class() -> bool:
	var cost : int = LvlConfig.get_stat_level_cost(class_level)
	if cost < 0 or GameData.xp_global < cost:
		return false

	GameData.xp_global -= cost
	class_level += 1

	resync_attributes()
	return true


func try_use_skill(skill: Skill, context: Dictionary) -> bool:
	if not skill.is_usable_in(GameManager.current_state):
		return false
	if skill.effect == null:
		return false

	var ep_cost := skill.get_ep_cost(self)
	var sp_cost := skill.get_sp_cost(self)

	if current_ep < ep_cost or current_sp < sp_cost:
		return false

	current_ep -= ep_cost
	current_sp -= sp_cost

	skill.effect.execute(self, context)
	return true

func set_row(new_row: PartyRow) -> void:
	row = new_row
