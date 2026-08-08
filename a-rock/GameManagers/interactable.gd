# interactable_object.gd
class_name InteractableObject
extends Area2D

func _ready() -> void:
	add_to_group("interactable")


func interact(player: Node) -> void:
	push_warning("interact() non implémenté pour : %s" % get_class())
