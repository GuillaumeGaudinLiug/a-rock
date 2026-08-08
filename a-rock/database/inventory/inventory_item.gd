# inventory_item.gd
class_name InventoryItem
extends Resource

enum ItemCategory { CONSUMABLE, MATERIAL, KEY }

@export var item_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var category: ItemCategory = ItemCategory.CONSUMABLE

@export_flags("Exploration", "Combat") var usable_contexts: int = 1  # pertinent seulement si CONSUMABLE
@export var effect: AbstractEffect  # pertinent seulement si CONSUMABLE

@export var stackable: bool = true
@export var max_stack: int = 20

func is_usable_in(state: GameManager.GameState) -> bool:
	if category != ItemCategory.CONSUMABLE:
		return false
	match state:
		GameManager.GameState.EXPLORATION: return usable_contexts & 1 != 0
		GameManager.GameState.COMBAT: return usable_contexts & 2 != 0
		_: return false
