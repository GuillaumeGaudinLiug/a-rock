# vfx_step.gd
class_name VfxStep
extends Resource

# context contient : "caster_view", "target_view" (CombatTargetView)
func play(context: Dictionary) -> void:
	push_warning("play() non implémenté pour : %s" % get_class())
