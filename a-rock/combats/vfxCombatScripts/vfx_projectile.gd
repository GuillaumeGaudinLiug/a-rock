class_name VfxStepProjectile
extends VfxStep

@export var sprite_frames: SpriteFrames
@export var speed: float = 600.0
@export var rotate_to_target: bool = false


func play(context: Dictionary) -> void:
	var caster_view: CombatTargetView = context.get("caster_view")
	var target_view: CombatTargetView = context.get("target_view")
	var parent: Node = context.get("vfx_parent")
	if caster_view == null or target_view == null or parent == null:
		return

	var projectile := AnimatedSprite2D.new()
	projectile.sprite_frames = sprite_frames
	projectile.global_position = caster_view.global_position
	parent.add_child(projectile)

	if sprite_frames.has_animation("default"):
		projectile.play("default")

	var start_pos := caster_view.global_position
	var end_pos := target_view.global_position
	var duration := start_pos.distance_to(end_pos) / speed

	if rotate_to_target:
		projectile.rotation = start_pos.angle_to_point(end_pos)

	var tween := projectile.create_tween()
	tween.tween_property(projectile, "global_position", end_pos, duration)
	await tween.finished

	projectile.queue_free()
