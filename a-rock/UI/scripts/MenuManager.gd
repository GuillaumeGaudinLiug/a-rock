extends Node

const MENU_SCENE := preload("res://UI/scenes/ExplorationMenu.tscn")

var menu_instance: CanvasLayer

@onready var interact_label: Label = $HudLayer/InteractLabel
@onready var message_label: Label = $HudLayer/MessageLabel

var message_queue: Array[Dictionary] = []
var message_timer: float = 2.0
var is_showing_message: bool = false


func _ready() -> void:
	menu_instance = MENU_SCENE.instantiate()
	add_child(menu_instance)
	menu_instance.hide()
	menu_instance.close_requested.connect(close_menu)

	interact_label.hide()
	message_label.hide()


func _process(delta: float) -> void:
	if not is_showing_message:
		if not message_queue.is_empty():
			_show_next_message()
		return

	message_timer -= delta
	if message_timer <= 0.0:
		message_label.hide()
		is_showing_message = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_menu") and GameManager.is_state(GameManager.GameState.EXPLORATION):
		open_menu()


func open_menu() -> void:
	menu_instance.show()
	menu_instance.refresh()
	GameManager.push_state(GameManager.GameState.MENU)


func close_menu() -> void:
	menu_instance.hide()
	GameManager.pop_state()


func set_interact_prompt_visible(is_visible: bool, text: String = "Interact") -> void:
	interact_label.text = text
	interact_label.visible = is_visible and GameManager.is_state(GameManager.GameState.EXPLORATION)


func show_message(text: String, duration: float = 2.0) -> void:
	message_queue.append({ "text": text, "duration": duration })


func _show_next_message() -> void:
	var entry: Dictionary = message_queue.pop_front()
	message_label.text = entry["text"]
	message_label.show()
	message_timer = entry["duration"]
	is_showing_message = true
