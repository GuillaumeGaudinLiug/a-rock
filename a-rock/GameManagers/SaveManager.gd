extends Node

const SAVE_DIR := "user://saves/"
const SAVE_PASSWORD := "4a94c9c5-fbf6-41eb-b1cf-b40515040fcb"


@export var use_encryption: bool = false


func save_game(slot: int) -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

	var data := {
		"adversity": GameData.adversity,
		"party_size": GameData.partySize,
		"party": GameData.party.map(func(member): return member.to_dict()),
		"inventory": GameData.inventory,
		"xp_global": GameData.xp_global,
		"current_scene_path": GameData.current_scene_path,
		"story_flags": GameData.story_flags,
		"chest_flags": GameData.chest_flags,
		"cycle_number": GameData.cycle_number,
	}

	var path := SAVE_DIR + "slot_%d.save" % slot
	var file: FileAccess

	if use_encryption:
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SAVE_PASSWORD)
	else:
		file = FileAccess.open(path, FileAccess.WRITE)

	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func load_game(slot: int) -> bool:
	var path := SAVE_DIR + "slot_%d.save" % slot
	if not FileAccess.file_exists(path):
		push_warning("Aucune sauvegarde trouvée pour le slot %d." % slot)
		return false

	var file: FileAccess
	if use_encryption:
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SAVE_PASSWORD)
	else:
		file = FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_warning("Sauvegarde corrompue ou modifiée (slot %d)." % slot)
		return false

	var text := file.get_as_text()
	file.close()

	var data: Dictionary = JSON.parse_string(text)
	if data == null:
		push_warning("Fichier de sauvegarde corrompu (slot %d)." % slot)
		return false

	GameData.adversity = data["adversity"]
	GameData.partySize = data["party_size"]

	GameData.party = []
	for member_data in data["party"]:
		GameData.party.append(CharacterInstance.from_dict(member_data))

	GameData.inventory = data["inventory"]
	GameData.xp_global = data["xp_global"]
	GameData.current_scene_path = data["current_scene_path"]
	GameData.story_flags = data["story_flags"]
	GameData.chest_flags = data["chest_flags"]
	GameData.cycle_number = data["cycle_number"]

	return true
