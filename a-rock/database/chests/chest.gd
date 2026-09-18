@tool
class_name Chest
extends InteractableObject

@export var chest_id: String = ""
@export var regenerate_id: bool = false:
	set(value):
		if value:
			chest_id = _generate_uuid()
		regenerate_id = false

@export var loot: Array[LootEntry] = []
@export var use_sfx: AudioStream

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	super._ready()

	if Engine.is_editor_hint():
		return

	if GameData.chest_flags.has(chest_id):
		sprite.play("opened")
	else :
		sprite.play("closed")


func _generate_uuid() -> String:
	var chars := "0123456789abcdef"
	var uuid := ""
	for i in 32:
		uuid += chars[randi() % chars.length()]
		if i in [7, 11, 15, 19]:
			uuid += "-"
	return uuid


func _do_interact(player: Node) -> bool:
	if GameData.chest_flags.has(chest_id):
		return false

	GameData.chest_flags.append(chest_id)

	for entry in loot:
		GameData.add_item(entry.item, entry.quantity)
		MenuManager.show_message("Received : %s x%d" % [entry.item.item_name, entry.quantity])

	sprite.play("opened")
	if use_sfx != null:
		SfxManager.play(use_sfx)
	# wait
	await get_tree().create_timer(0.5).timeout  # laisse le temps de voir l'animation avant de redonner le contrôle
	return false
