extends Area2D

@export var target_spawn: Marker2D
@export var target_room: Node2D  # la Room de destination (doit avoir la méthode apply_camera_limits)

var can_transition: bool = true


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if not can_transition:
		return

	can_transition = false
	body.global_position = target_spawn.global_position

	if target_room != null and target_room.has_method("apply_camera_limits"):
		target_room.apply_camera_limits()

	await get_tree().create_timer(0.3).timeout
	can_transition = true
