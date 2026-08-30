class_name VfxStepImpact
extends VfxStep

@export var sprite_frames: SpriteFrames


func play(context: Dictionary) -> void:
	var target_view: CombatTargetView = context.get("target_view")
	var parent: Node = context.get("vfx_parent")
	if target_view == null or parent == null or sprite_frames == null:
		return

	var vfx := AnimatedSprite2D.new()
	vfx.sprite_frames = sprite_frames
	vfx.global_position = target_view.global_position
	parent.add_child(vfx)

	if sprite_frames.has_animation("default"):
		vfx.play("default")
		await vfx.animation_finished
	else:
		await parent.get_tree().create_timer(0.4).timeout

	vfx.queue_free()
