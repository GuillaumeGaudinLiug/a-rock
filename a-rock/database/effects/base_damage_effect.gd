class_name BaseDamageEffect
extends AbstractEffect


@export var amount: int = 10
@export_range(0.0, 1.0, 0.01) var variance: float = 0.15
@export_range(0.0, 5.0, 0.01) var att_determination_multiplier = 1.5
@export_range(0.0, 5.0, 0.01) var att_passion_multiplier = 0.5
@export_range(0.0, 5.0, 0.01) var def_courage_multiplier = 1
@export_range(0.0, 5.0, 0.01) var def_spirit_multiplier = 0.25

@export_range(0.0, 5.0, 0.01) var def_backrow_multiplier = 1.5
@export_range(0.0, 5.0, 0.01) var att_backrow_multiplier = 0.5

func _execute(context: Dictionary,result : EffectResult) -> void:
	var user = context.get("user")

	var target = context.get("target")
	
	if target == null:
		return
	# Score d'att et de def
	var att_row = 1.0 if user.row == CharacterInstance.PartyRow.FRONT else att_backrow_multiplier
	var att = int(amount + user.determination * att_determination_multiplier + user.passion * att_passion_multiplier) * att_row
	var def_row = def_backrow_multiplier if target.row == CharacterInstance.PartyRow.BACK else 1.0
	var def = int(target.courage * def_courage_multiplier + target.spirit * def_spirit_multiplier)
	
	var multiplier := 1.0 + randf_range(-variance, variance)

	var formula = max(1, int((att - def)/def_row * multiplier))
	target.current_ep = max(target.current_ep - formula, 0) 
	
	result.hit = true
	result.value = formula
	result.kind = EffectResult.Kind.DAMAGE
	print("Damage result: " + str(result.value))
	return 
