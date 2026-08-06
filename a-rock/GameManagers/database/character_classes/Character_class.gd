# character_class.gd
class_name CharacterClass
extends Resource

@export var class_name_display: String = ""
@export var combat_sprite_frames: SpriteFrames  # animations utilisées en combat
@export var idle_sprite_frame: SpriteFrames  # animations utilisées en combat

@export_group("Statistiques de base")
@export var base_determination: int = 5
@export var base_courage: int = 5
@export var base_passion: int = 5
@export var base_spirit: int = 5
@export var base_adaptability: int = 5
@export var base_max_ep: int = 100
@export var base_max_sp: int = 10

@export var default_weapon: Weapon
@export var class_levels : Array[ProgressionLevelEntry] = []
# TODO: Skills

func get_class_level_cost(current_class_level: int) -> int:
	var index := current_class_level - 1
	if index < 0 or index >= class_levels.size():
		return -1
	return class_levels[index].xp_required
