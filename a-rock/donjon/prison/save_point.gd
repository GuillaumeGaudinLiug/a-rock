@tool
class_name SavePoint
extends Area2D

@export var size: Vector2 = Vector2(48, 48):
	set(value):
		size = value
		_update_shape()
		queue_redraw()

@export var save_slot: int = 0
@export var show_debug_rect: bool = true

var can_save: bool = true

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sfx: AudioStreamPlayer = $SFX


func _ready() -> void:
	_update_shape()
	queue_redraw()

	if Engine.is_editor_hint():
		return

	body_entered.connect(_on_body_entered)


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
	draw_rect(Rect2(-half, size), Color(0.3, 0.8, 1.0, 0.15), true)
	draw_rect(Rect2(-half, size), Color(0.3, 0.8, 1.0, 0.9), false, 2.0)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not can_save:
		return

	can_save = false

	GameData.current_scene_path = get_tree().current_scene.scene_file_path

	SaveManager.save_game(save_slot)
	MenuManager.show_message("Game Saved")
	
	if sfx != null:
		sfx.play()

	print("Partie sauvegardée (slot %d)." % save_slot)

	await get_tree().create_timer(0.5).timeout
	can_save = true
