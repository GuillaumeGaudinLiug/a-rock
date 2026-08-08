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
var cycle_number : int = 1



func add_item(item: InventoryItem, quantity: int = 1) -> void:
	var key := item.resource_path
	inventory[key] = inventory.get(key, 0) + quantity


func remove_item(item: InventoryItem, quantity: int = 1) -> bool:
	var key := item.resource_path
	var current: int = inventory.get(key, 0)
	if current < quantity:
		return false
	current -= quantity
	if current <= 0:
		inventory.erase(key)
	else:
		inventory[key] = current
	return true


func get_item_count(item: InventoryItem) -> int:
	return inventory.get(item.resource_path, 0)
