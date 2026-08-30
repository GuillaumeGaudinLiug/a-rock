extends Node2D
class_name CombatSceneAnimator

var view_by_participant: Dictionary = {}
@onready var vfx_layer: Node2D = $VfxLayer

# Trouve l'animation du skill
func _play_action_animation(actor: CombatParticipant, action: CombatAction) -> void:
	var view: CombatTargetView = view_by_participant.get(actor)
	if view == null:
		return

	# Lancer le frame specific du skill
	if action.type == CombatAction.ActionType.SKILL and action.skill != null:
		var frames := action.skill.get_animation_frames(actor.get_animation_set())
		view.sprite.sprite_frames = frames
		if frames != null and frames.has_animation("default"):
			view.sprite.play("default")
		return

	# Lancement de l'animation de combat par defaut
	var frames := actor.get_animation_set().get_frames(CombatAnimationSet.State.COMBAT)
	view.sprite.sprite_frames = frames
	if frames != null and frames.has_animation("default"):
		view.sprite.play("default")


# Damage animation
func _play_damage_animation(p: CombatParticipant) -> void:
	if not p.is_alive() or not p.is_player:
		return  # un participant déjà KO garde son animation KO, pas de "damage" par-dessus

	var view: CombatTargetView = view_by_participant.get(p)
	if view == null:
		return

	var frames := p.get_animation_set().get_frames(CombatAnimationSet.State.DAMAGE)
	if frames == null:
		return

	view.sprite.sprite_frames = frames
	if frames.has_animation("default"):
		view.sprite.play("default")

	await get_tree().create_timer(0.5).timeout

	if p.is_alive():
		var idle_frames := p.get_idle_frames()
		view.sprite.sprite_frames = idle_frames
		if idle_frames != null and idle_frames.has_animation("default"):
			view.sprite.play("default")


# Play target impact sprite
func _play_impact_vfx(target: CombatParticipant, frames: SpriteFrames) -> void:
	var vfx := AnimatedSprite2D.new()
	vfx.sprite_frames = frames
	vfx.position = target.world_position
	vfx_layer.add_child(vfx)
	if frames.has_animation("default"):
		vfx.play("default")
		await vfx.animation_finished
	else:
		await get_tree().create_timer(0.5).timeout
	vfx.queue_free()


func _flash_hit(sprite: AnimatedSprite2D) -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)


# Retour à l'animation idle
func _reset_to_idle(p: CombatParticipant) -> void:
	var view: CombatTargetView = view_by_participant.get(p)
	if view == null or not p.is_alive():
		return  # un participant KO garde son animation KO, pas l'idle
	var frames := p.get_idle_frames()
	view.sprite.sprite_frames = frames
	if frames != null and frames.has_animation("default"):
		view.sprite.play("default")
