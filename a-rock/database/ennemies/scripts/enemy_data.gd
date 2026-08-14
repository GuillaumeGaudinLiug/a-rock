# enemy_data.gd
class_name EnemyData
extends Resource

@export var enemy_name: String = ""
@export var combat_sprite_frames: SpriteFrames
# Ressource de l'IA des comportement en combat
@export var behavior: EnemyBehavior
@export var innate_statuses: Array[StatusEffect] = []
@export var statuses_immune: Array[StatusEffect] = []

@export_group("Statistiques")
@export var determination: int = 1
@export var courage: int = 1
@export var passion: int = 1
@export var spirit: int = 1
@export var adaptability: int = 1
@export var max_ep: int = 20
@export var max_sp: int = 20

@export_group("Récompenses")
@export var xp_value: int = 10
@export var loot_table: LootDropEntry
