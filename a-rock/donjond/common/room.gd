extends Node2D

@export var size: Vector2 = Vector2(800, 600)
@export var wall_thickness: float = 20.0
@export var camera: Camera2D

@onready var zone: Area2D = $Zone
@onready var zone_shape: CollisionShape2D = $Zone/CollisionShape2D
@onready var wall_top: CollisionShape2D = $Walls/WallTop
@onready var wall_bottom: CollisionShape2D = $Walls/WallBottom
@onready var wall_left: CollisionShape2D = $Walls/WallLeft
@onready var wall_right: CollisionShape2D = $Walls/WallRight


func _ready() -> void:
	_setup_shapes()
	zone.body_entered.connect(_on_body_entered)


func _setup_shapes() -> void:
	var half := size / 2.0

	var zone_rect := RectangleShape2D.new()
	zone_rect.size = size
	zone_shape.shape = zone_rect

	_configure_wall(wall_top, Vector2(0, -half.y), Vector2(size.x, wall_thickness))
	_configure_wall(wall_bottom, Vector2(0, half.y), Vector2(size.x, wall_thickness))
	_configure_wall(wall_left, Vector2(-half.x, 0), Vector2(wall_thickness, size.y))
	_configure_wall(wall_right, Vector2(half.x, 0), Vector2(wall_thickness, size.y))


func _configure_wall(collision_shape: CollisionShape2D, local_pos: Vector2, wall_size: Vector2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = wall_size
	collision_shape.shape = shape
	collision_shape.position = local_pos


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if camera == null:
		return

	var half := size / 2.0
	camera.limit_left = int(global_position.x - half.x)
	camera.limit_top = int(global_position.y - half.y)
	camera.limit_right = int(global_position.x + half.x)
	camera.limit_bottom = int(global_position.y + half.y)
