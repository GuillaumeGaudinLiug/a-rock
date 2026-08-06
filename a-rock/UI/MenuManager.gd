# MenuManager.gd (Autoload)
extends Node

const MENU_SCENE := preload("res://UI/ExplorationMenu.tscn")

var menu_instance: CanvasLayer


func _ready() -> void:
	menu_instance = MENU_SCENE.instantiate()
	add_child(menu_instance)
	menu_instance.hide()
	menu_instance.close_requested.connect(close_menu)


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
