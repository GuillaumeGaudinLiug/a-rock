@tool
class_name DoorPoint
extends Area2D

@export var size: Vector2 = Vector2(64, 64):
	set(value):
		size = value
		_update_shape()
		queue_redraw()

@export var show_debug_rect: bool = true

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	_update_shape()
	queue_redraw()
	body_entered.connect(func(body): print(name, " touché par ", body.name))


func _update_shape() -> void:
	if not is_inside_tree():
		return
	var shape := RectangleShape2D.new()
	shape.size = size
	collision_shape.shape = shape


func _draw() -> void:
	if not show_debug_rect:
		return
	var half := size / 2.0
	draw_rect(Rect2(-half, size), Color(1.0, 0.6, 0.0, 0.15), true)
	draw_rect(Rect2(-half, size), Color(1.0, 0.6, 0.0, 0.9), false, 2.0)
