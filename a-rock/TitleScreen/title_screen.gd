extends Control

@onready var new_game_button: Button = $NewGameButton
@onready var load_game_button: Button = $LoadGameButton


func _ready() -> void:
	GameManager.change_state(GameManager.GameState.TITLESCREEN)
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)


func _on_new_game_pressed() -> void:
	GameManager.goto_scene("res://TitleScreen/CharacterCreation.tscn", GameManager.GameState.TITLESCREEN)


func _on_load_game_pressed() -> void:
	GameManager.goto_scene("res://TitleScreen/LoadGameScene.tscn", GameManager.GameState.TITLESCREEN)
