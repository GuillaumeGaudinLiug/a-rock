# item_effect.gd
class_name AbstractEffect
extends Resource

func execute(user: CharacterInstance, context: Dictionary) -> void:
	push_warning("ItemEffect.execute() non implémenté pour : %s" % get_class())
