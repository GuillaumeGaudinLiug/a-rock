@tool
class_name Obstacle
extends StaticBody2D

@export var size: Vector2 = Vector2(32, 32):
	set(value):
		size = value
		_update_shape()
		queue_redraw()

@export var show_debug_rect: bool = true

var collision_shape: CollisionShape2D


func _ready() -> void:
	_ensure_collision_shape()
	_update_shape()
	queue_redraw()


func _ensure_collision_shape() -> void:
	if collision_shape != null:
		return

	# Cherche un enfant existant (au cas où il aurait été ajouté manuellement dans l'éditeur)
	for child in get_children():
		if child is CollisionShape2D:
			collision_shape = child
			return

	# Sinon, on le crée nous-mêmes
	collision_shape = CollisionShape2D.new()
	add_child(collision_shape)
	if Engine.is_editor_hint():
		collision_shape.owner = get_tree().edited_scene_root


func _update_shape() -> void:
	_ensure_collision_shape()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision_shape.shape = shape


func _draw() -> void:
	if not show_debug_rect:
		return
	var half := size / 2.0
	draw_rect(Rect2(-half, size), Color(0.6, 0.4, 0.2, 0.15), true)
	draw_rect(Rect2(-half, size), Color(0.6, 0.4, 0.2, 0.9), false, 2.0)
