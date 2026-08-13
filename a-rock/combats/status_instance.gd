# status_instance.gd — runtime, pas une Resource
class_name StatusInstance
extends RefCounted

var status: StatusEffect
var remaining_turns: int
var stacks: int = 1

func _init(s: StatusEffect) -> void:
	status = s
	remaining_turns = s.duration_turns
