class_name VfxStepParticleEmit
extends VfxStep

@export var sprite_frames: SpriteFrames
@export var particle_count: int = 6
@export var end_radius: float = 60.0
@export var duration: float = 0.4


func play(context: Dictionary) -> void:
	var target_view: CombatTargetView = context.get("target_view")
	var parent: Node = context.get("vfx_parent")
	if target_view == null or parent == null:
		return

	var center := target_view.global_position
	var particles: Array[AnimatedSprite2D] = []
	var targets_pos: Array[Vector2] = []

	for i in particle_count:
		var angle := (TAU / particle_count) * i
		var offset := Vector2(cos(angle), sin(angle)) * end_radius

		var p := AnimatedSprite2D.new()
		p.sprite_frames = sprite_frames
		p.global_position = center
		parent.add_child(p)
		if sprite_frames.has_animation("default"):
			p.play("default")
		particles.append(p)
		targets_pos.append(center + offset)

	var tween := parent.create_tween()
	tween.set_parallel(true)
	for i in particles.size():
		tween.tween_property(particles[i], "global_position", targets_pos[i], duration)
		tween.tween_property(particles[i], "modulate:a", 0.0, duration)
	await tween.finished

	for p in particles:
		p.queue_free()
