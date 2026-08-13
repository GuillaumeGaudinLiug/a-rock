# stat_modifier.gd
class_name StatModifier
extends Resource

@export var stat_name: String = "courage"
@export var flat_amount: float = 0.0
@export_range(-1.0, 2.0, 0.01) var percent_amount: float = 0.0
