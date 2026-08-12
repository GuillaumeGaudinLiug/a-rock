class_name LootDropEntry
extends Resource

@export var item: InventoryItem
@export_range(0.0, 1.0, 0.01) var drop_chance: float = 0.3
@export var quantity: int = 1
