# GameData.gd (Autoload)
extends Node

var adversity : int
var partySize : int
var party: Array[CharacterInstance] = []
var inventory: Dictionary = {}   # ex: { "potion": 3, "elixir": 1 }
var xp_global: int = 0
var current_scene_path: String = ""
var story_flags: Dictionary = {}  # ex: { "boss_forest_defeated": true }
var chest_flags: Dictionary = {}  # ex: { "Zone1_chest1": true }
