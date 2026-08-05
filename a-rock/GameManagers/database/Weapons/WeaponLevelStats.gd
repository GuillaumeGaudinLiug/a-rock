# weapon_level_stats.gd
class_name WeaponLevelStats
extends ProgressionLevelEntry

@export var determination: int = 0
@export var courage: int = 0
@export var passion: int = 0
@export var spirit: int = 0
@export var adaptability: int = 0
@export var max_ep: int = 0
@export var max_sp: int = 0


func get_stat(stat_name: String) -> int:
	match stat_name:
		"determination": return determination
		"courage": return courage
		"passion": return passion
		"spirit": return spirit
		"adaptability": return adaptability
		"max_ep": return max_ep
		"max_sp": return max_sp
		_: return 0
