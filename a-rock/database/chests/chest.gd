# chest.gd
class_name Chest
extends InteractableObject

@export var chest_id: String = ""  # identifiant unique, ex: "zone1_chest1"
@export var loot: Array[LootEntry] = []

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	super._ready()
	if GameData.chest_flags.get(chest_id, false):
		sprite.play("opened")


func interact(player: Node) -> void:
	if GameData.chest_flags.get(chest_id, false):
		return

	GameData.chest_flags[chest_id] = true

	for entry in loot:
		GameData.add_item(entry.item, entry.quantity)

	sprite.play("opening")
	print("Coffre ouvert : ", chest_id)
