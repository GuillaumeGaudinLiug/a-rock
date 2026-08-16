# item_effect_heal.gd
class_name HealRawEffect
extends AbstractEffect

@export var amount: int = 20
@export_range(0.0, 1.0, 0.01) var percentage: float = 0.1


func _execute(context: Dictionary, result : EffectResult) -> void:
	var target = context.get("target")
	if target == null:
		return
	
	var healing_amount :int = amount + target.max_ep * percentage
	result.value = healing_amount
	
	target.current_ep = min(
		target.current_ep + healing_amount, target.max_ep
		)
