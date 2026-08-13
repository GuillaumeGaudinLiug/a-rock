class_name AbstractEffect
extends Resource

@export var use_sfx: AudioStream
@export var can_miss: bool = false


func execute(context: Dictionary) -> bool:
	if can_miss and not _resolve_hit(context):
		_on_miss(context)
		return false
	# Lancer le bruit de l'effet uniquement si la resource possédent le son
	if use_sfx != null:
		SfxManager.play(use_sfx)
	_execute(context)
	return true

# Formule pour le calcul de miss
func _resolve_hit(context: Dictionary) -> bool:
	var user = context.get("user")
	var target = context.get("target")
	#if user != null and target != null:
		
	# TODO: formula
	return randf() < 0

func _on_miss(context: Dictionary) -> void:
	var user = context.get("user")
	var target = context.get("target")
	if user != null and target != null:
		print("%s rate son action sur %s" % [user.display_name, target.display_name])
		# TODO: lancement d'animation de miss + sound
		#SfxManager.play(miss_sfx)
 
func _execute(_context: Dictionary) -> void:
	push_warning("_execute() non implémenté pour : %s" % get_class())
