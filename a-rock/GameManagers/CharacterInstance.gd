# character_instance.gd
class_name CharacterInstance
extends RefCounted

var class_level : int
var character_class: String # TODO: Classe à prévoir
var determination: int
var courage: int
var passion: int
var spirit:int
var adaptability: int
var max_ep: int
var max_sp: int
var current_ep: int
var current_sp: int
var equipped_weapon: String # TODO: Classe à prevoir
var weapon_levels: Dictionary = {}  # ex: { "res://weapons/sword.tres": 3 }
var stat_levels: Dictionary = {}

func _init() -> void:
	# Calculate each stats with defaut value of Classe; stat_levels, weapons_levels
	return
	#if cls == null:
		#return
	#character_class = cls
	#equipped_weapon = cls.default_weapon
	#current_hp = cls.base_hp
	#current_mp = cls.base_mp

func resync_attributes() -> CharacterInstance:
	return self

func to_dict() -> Dictionary:
	return {
		"class_level": class_level,
		"character_class": character_class,
		"max_ep": max_ep,
		"max_sp": max_sp,
		"equipped_weapon": equipped_weapon,
		"weapon_levels": weapon_levels,
		"stat_levels": stat_levels,
	}


static func from_dict(data: Dictionary) -> CharacterInstance:
	var instance := CharacterInstance.new()
	instance.class_level = data["class_level"]
	instance.character_class = data["character_class"]
	instance.max_ep = data["max_ep"]
	instance.max_sp = data["max_sp"]
	instance.equipped_weapon = data["equipped_weapon"]
	instance.weapon_levels = data["weapon_levels"]
	instance.stat_levels = data["stat_levels"]
	return instance
