class_name AbstractEffect
extends Resource

@export var use_sfx: AudioStream


func execute(user: CharacterInstance, context: Dictionary) -> void:
	SfxManager.play(use_sfx)
	_execute(user, context)


func _execute(user: CharacterInstance, context: Dictionary) -> void:
	push_warning("_execute() non implémenté pour : %s" % get_class())
