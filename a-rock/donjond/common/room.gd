@tool
extends Node2D

@export var show_debug_rect: bool = true
@export var size: Vector2 = Vector2(800, 600):
	set(value):
		size = value
		if is_node_ready():
			_setup_shapes()
		queue_redraw()
@export var wall_thickness: float = 20.0
@export var camera_override: Camera2D  # optionnel : pour un cas particulier (cutscene, etc.)
@export var spawn_from_room: Marker2D
@export var spawn_from_room2: Marker2D

var camera: Camera2D

@onready var zone: Area2D = $Zone
@onready var zone_shape: CollisionShape2D = $Zone/CollisionShape2D
@onready var wall_top: CollisionShape2D = $Walls/WallTop
@onready var wall_bottom: CollisionShape2D = $Walls/WallBottom
@onready var wall_left: CollisionShape2D = $Walls/WallLeft
@onready var wall_right: CollisionShape2D = $Walls/WallRight
@onready var spawn_points: Node2D = $SpawnPoints


func _ready() -> void:
	_setup_shapes()
	queue_redraw()

	if Engine.is_editor_hint():
		return

	camera = camera_override if camera_override != null else _find_default_camera()
	zone.body_entered.connect(_on_body_entered)

	await get_tree().physics_frame
	for body in zone.get_overlapping_bodies():
		_on_body_entered(body)


func _find_default_camera() -> Camera2D:
	var found := get_tree().get_first_node_in_group("main_camera")
	if found == null:
		push_warning("Room: aucune caméra trouvée dans le groupe 'main_camera'.")
		return null
	return found as Camera2D

# ... le reste du script (_setup_shapes, _configure_wall, _on_body_entered) ne change pas

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


func apply_camera_limits() -> void:
	if camera == null:
		return
	var half := size / 2.0
	camera.limit_left = int(global_position.x - half.x)
	camera.limit_top = int(global_position.y - half.y)
	camera.limit_right = int(global_position.x + half.x)
	camera.limit_bottom = int(global_position.y + half.y)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	apply_camera_limits()


func get_spawn_point(spawn_name: String) -> Marker2D:
	if spawn_points.has_node(spawn_name):
		return spawn_points.get_node(spawn_name)
	push_warning("Room '%s': point de spawn '%s' introuvable." % [name, spawn_name])
	return null
	
	
	


func _draw() -> void:
	if not show_debug_rect:
		return
	var half := size / 2.0
	var rect := Rect2(-half, size)
	draw_rect(rect, Color(0.2, 1.0, 0.2, 0.12), true)       # remplissage léger
	draw_rect(rect, Color(0.2, 1.0, 0.2, 0.9), false, 2.0)  # contour net
