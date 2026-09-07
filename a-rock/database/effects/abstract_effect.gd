class_name AbstractEffect
extends Resource

#signal effect_applied(target, result: EffectResult)

@export var use_sfx: AudioStream
@export var can_miss: bool = false
@export var miss_sfx: AudioStream


func execute(context: Dictionary) -> EffectResult:
	var result := EffectResult.new()
	result.effect_name = get_class()

	if can_miss and not _resolve_hit(context):
		if miss_sfx != null:
			SfxManager.play(miss_sfx)
		result.hit = false
		result.kind = EffectResult.Kind.MISS

		result.value_label = "Raté !"
		_on_miss(context)
		EffectSignalBus.effect_applied.emit(context.get("target"), result)

		return result

	if use_sfx != null:	SfxManager.play(use_sfx)
	_execute(context, result)
	# Envoi d'un signal
	#effect_applied.emit(context.get("target"), result)
	EffectSignalBus.effect_applied.emit(context.get("target"), result)

	return result

# Formule pour le calcul de miss
func _resolve_hit(context: Dictionary) -> bool:
	var user = context.get("user")
	var target = context.get("target")
	#if user != null and target != null:
		
	# Formule d'esquive
	var ratio: float = user.adaptability / max(target.adaptability, 0.01)
	var log2_ratio: float = log(ratio) / log(2.0)
	var modifier: float = clamp(log2_ratio * 0.1, -0.1, 0.1)

	var chance: float = clamp(0.9 + modifier, 0.01, 0.99)
	return randf() > 0

func _on_miss(context: Dictionary) -> void:
	var user = context.get("user")
	var target = context.get("target")
	if user != null and target != null:
		print("%s rate son action sur %s" % [user.display_name, target.display_name])
		# TODO: lancement miss  sound
		#SfxManager.play(miss_sfx)
		
 
func _execute(context: Dictionary, result: EffectResult) -> void:
	push_warning("_execute() non implémenté pour : %s" % get_class())
