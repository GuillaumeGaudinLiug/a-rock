extends CharacterBody2D

@export var speed: float = 150.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_zone: Area2D = $InteractionZone
var nearby_interactables: Array[InteractableObject] = []

var last_direction: String = "down"

func _ready() -> void:
	interaction_zone.area_entered.connect(_on_interactable_entered)
	interaction_zone.area_exited.connect(_on_interactable_exited)

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

	update_animation(direction)


func update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		animated_sprite.stop()
		return

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			last_direction = "right"
			animated_sprite.flip_h = true
			animated_sprite.play("walkleft")  # on rejoue l'anim gauche, flippée
		else:
			last_direction = "left"
			animated_sprite.flip_h = false
			animated_sprite.play("walkleft")
	else:
		last_direction = "down" if direction.y > 0 else "up"
		animated_sprite.flip_h = false
		animated_sprite.play("walk" + last_direction)


func _on_interactable_entered(area: Area2D) -> void:
	if area is InteractableObject:
		nearby_interactables.append(area)


func _on_interactable_exited(area: Area2D) -> void:
	if area is InteractableObject:
		nearby_interactables.erase(area)


func _unhandled_input(event: InputEvent) -> void:
	if not GameManager.is_state(GameManager.GameState.EXPLORATION):
		return
	if event.is_action_pressed("interact") and not nearby_interactables.is_empty():
		nearby_interactables[0].interact(self)
