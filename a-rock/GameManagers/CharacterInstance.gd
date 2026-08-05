# character_instance.gd
class_name CharacterInstance
extends RefCounted

# Champs modifiables par opération de lvlup et sauvegardables
var class_level : int = 0
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

var status: Array[String] # TODO : statuts effect


func _init() -> void:
	
	return


func resync_attributes() -> CharacterInstance:
	var cls: CharacterClass = load(character_class)
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
		var weapon_level: int = weapon_levels.get(equipped_weapon, 1)

		determination += equipped_weapon.get_stat_bonus("determination", weapon_level)
		courage += equipped_weapon.get_stat_bonus("courage", weapon_level)
		passion += equipped_weapon.get_stat_bonus("passion", weapon_level)
		spirit += equipped_weapon.get_stat_bonus("spirit", weapon_level)
		adaptability += equipped_weapon.get_stat_bonus("adaptability", weapon_level)
		max_ep += equipped_weapon.get_stat_bonus("max_ep", weapon_level)
		max_sp += equipped_weapon.get_stat_bonus("max_sp", weapon_level)

	return self

func to_dict() -> Dictionary:
	return {
		"class_level": class_level,
		"character_class": character_class,
		"equipped_weapon": equipped_weapon,
		"weapon_levels": weapon_levels,
		"determination_lvl": determination_lvl,
		"courage_lvl": courage_lvl,
		"passion_lvl": passion_lvl,
		"spirit_lvl": spirit_lvl,
		"adaptability_lvl": adaptability_lvl
	}


static func from_dict(data: Dictionary) -> CharacterInstance:
	var instance := CharacterInstance.new()
	instance.class_level = data["class_level"]
	instance.character_class = data["character_class"]
	instance.equipped_weapon = data["equipped_weapon"]
	instance.weapon_levels = data["weapon_levels"]
	instance.determination_lvl = data["determination_lvl"]
	instance.courage_lvl = data["courage_lvl"]
	instance.passion_lvl = data["passion_lvl"]
	instance.spirit_lvl = data["spirit_lvl"]
	instance.adaptability_lvl = data["adaptability_lvl"]
	return instance
