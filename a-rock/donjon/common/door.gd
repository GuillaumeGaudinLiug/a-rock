@tool
class_name Door
extends Node2D

@export var room_a: Room
@export var room_b: Room

var can_transition: bool = true

@onready var point_a: Area2D = $PointA
@onready var point_b: Area2D = $PointB


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	point_a.body_entered.connect(_on_point_a_entered)
	point_b.body_entered.connect(_on_point_b_entered)


func _on_point_a_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not can_transition:
		return
	_teleport(body, point_b, room_b)


func _on_point_b_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not can_transition:
		return
	_teleport(body, point_a, room_a)


func _teleport(body: Node2D, target_point: Area2D, target_room: Room) -> void:
	can_transition = false
	body.global_position = target_point.global_position
	if target_room != null:
		target_room.apply_camera_limits()

	await get_tree().create_timer(0.3).timeout
	can_transition = true
