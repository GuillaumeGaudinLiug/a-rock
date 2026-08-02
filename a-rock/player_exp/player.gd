extends CharacterBody2D

@export var speed: float = 200.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var last_direction: String = "down"

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
