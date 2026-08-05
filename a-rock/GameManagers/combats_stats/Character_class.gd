# character_class.gd
class_name CharacterClass
extends Resource

@export var class_name_display: String = ""
@export var combat_sprite_frames: SpriteFrames  # animations utilisées en combat

@export_group("Statistiques de base")
@export var base_determination: int = 5
@export var base_courage: int = 5
@export var base_passion: int = 5
@export var base_spirit: int = 5
@export var base_adaptability: int = 5
@export var base_max_ep: int = 100
@export var base_max_sp: int = 10

@export var default_weapon: Weapon

# TODO: Skills
