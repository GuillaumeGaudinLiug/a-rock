# load_game_screen.gd
extends Control

@onready var slots_container: VBoxContainer = $SlotsContainer

const SAVE_DIR := "user://saves/"


func _ready() -> void:
	_populate_slots()


func _populate_slots() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		return

	var dir := DirAccess.open(SAVE_DIR)
	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.ends_with(".save"):
			var slot_number := file_name.trim_prefix("slot_").trim_suffix(".save").to_int()
			_add_slot_button(slot_number)
		file_name = dir.get_next()


func _add_slot_button(slot_number: int) -> void:
	var button := Button.new()
	button.text = "Emplacement %d" % slot_number
	button.pressed.connect(func(): _on_slot_selected(slot_number))
	slots_container.add_child(button)


func _on_slot_selected(slot_number: int) -> void:
	if not SaveManager.load_game(slot_number):
		push_warning("Impossible de charger le slot %d." % slot_number)
		return

	var scene_to_load := GameData.current_scene_path
	if scene_to_load == "":
		push_warning("current_scene_path vide dans la sauvegarde, impossible de charger.")
		return

	GameManager.goto_scene(scene_to_load)
