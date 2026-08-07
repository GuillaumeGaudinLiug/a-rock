extends Control
signal back_requested

@onready var message_label: Label = $MessageLabel
@onready var confirm_button: Button = $ConfirmButton
@onready var back_button: Button = $BackButton


func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_pressed)
	back_button.pressed.connect(func(): back_requested.emit())


func refresh() -> void:
	var cost := GameData.xp_global / 2
	message_label.text = "Retourner à la prison coûtera %d XP (moitié de votre XP global : %d)." % [cost, GameData.xp_global]


func grab_initial_focus() -> void:
	confirm_button.grab_focus()


func _on_confirm_pressed() -> void:
	GameData.xp_global -= GameData.xp_global / 2
	MenuManager.close_menu()
	GameManager.goto_scene("res://donjon/prison/prison.tscn")
