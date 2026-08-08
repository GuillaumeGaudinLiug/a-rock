# item_effect_heal.gd
class_name HealRawEffect
extends AbstractEffect

@export var amount: int = 20
@export var percentage: int = 10


func execute(user: CharacterInstance, context: Dictionary) -> void:
	var target: CharacterInstance = context.get("target")
	if target == null:
		return
	target.current_ep = min(
		target.current_ep + amount + target.max_ep * percentage/100, target.max_ep
		)
