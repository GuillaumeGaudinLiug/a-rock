# combat_animation_set.gd
class_name CombatAnimationSet
extends Resource

enum State { COMBAT, DAMAGE, KO, SPELL, WEAK }

@export var combat: SpriteFrames
@export var damage: SpriteFrames
@export var ko: SpriteFrames
@export var spell: SpriteFrames
@export var weak: SpriteFrames


# Recuperer les SpriteFrames en pointant sur le STATE
func get_frames(state: State) -> SpriteFrames:
	match state:
		State.COMBAT: return combat
		State.DAMAGE: return damage
		State.KO: return ko
		State.SPELL: return spell
		State.WEAK: return weak
		_: return combat
