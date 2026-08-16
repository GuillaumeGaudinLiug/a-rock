class_name DamagePercent
extends AbstractEffect

@export var base_damage_ep: int = 5
@export_range(0.0, 1.0, 0.01) var damage_percent_ep: float = 0.1
@export var base_damage_sp: int = 0
@export_range(0.0, 1.0, 0.01) var damage_percent_sp: float = 0.1


func _execute(context: Dictionary, result: EffectResult) -> void:
	var target = context.get("target")
	if target == null:
		return

	var damage_ep := base_damage_ep + int (target.max_ep * damage_percent_ep)
	var damage_sp := base_damage_sp + int (target.max_sp * damage_percent_sp)


	target.current_ep = max(0, target.current_ep - damage_ep)
	target.current_sp = max (0, target.current_sp - damage_sp)
	result.value = damage_ep
	result.value2 = damage_percent_sp
	print("%s subit %d ep / %d sp  dégâts (statut damage percent)" % [target.display_name, damage_ep, damage_sp])
