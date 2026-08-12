@tool
class_name SceneDoor
extends InteractableObject

@export var size: Vector2 = Vector2(48, 48):
	set(value):
		size = value
		_update_shape()
		queue_redraw()

@export var target_scene_path: String
@export var target_spawn_name: String
@export var show_debug_rect: bool = true

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	super._ready()
	_update_shape()
	queue_redraw()


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
	draw_rect(Rect2(-half, size), Color(1.0, 0.4, 0.8, 0.15), true)
	draw_rect(Rect2(-half, size), Color(1.0, 0.4, 0.8, 0.9), false, 2.0)


func interact(player: Node) -> void:
	TransitionManager.request_transition(target_scene_path, target_spawn_name)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	MenuManager.set_interact_prompt_visible(true, "")


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	MenuManager.set_interact_prompt_visible(false)
