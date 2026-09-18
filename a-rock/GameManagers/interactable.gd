# interactable_object.gd
class_name InteractableObject
extends Area2D

@export var message_prompt : String = "!!!"
func _ready() -> void:
	add_to_group("interactable")


func interact(player: Node) -> void:
	if GameManager.is_interaction_locked:
		return

	GameManager.lock_interaction()
	var self_managed = await _do_interact(player)
	if not self_managed:
		GameManager.unlock_interaction()


func _do_interact(player: Node) -> bool:
	push_warning("_do_interact() non implémenté pour : %s" % get_class())
	return false
