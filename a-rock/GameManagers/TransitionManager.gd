extends Node

const LOADING_SCREEN_SCENE := preload("res://MainScenes/LoadingScreen.tscn")

var pending_spawn_name: String = ""


func request_transition(scene_path: String, spawn_name: String) -> void:
	pending_spawn_name = spawn_name
	_load_scene_async(scene_path)


func _load_scene_async(scene_path: String) -> void:
	var loading_screen: CanvasLayer = LOADING_SCREEN_SCENE.instantiate()
	add_child(loading_screen)

	await loading_screen.fade_to_black()

	ResourceLoader.load_threaded_request(scene_path)

	var status := ResourceLoader.load_threaded_get_status(scene_path)
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		status = ResourceLoader.load_threaded_get_status(scene_path)

	if status != ResourceLoader.THREAD_LOAD_LOADED:
		push_warning("Échec du chargement de la scène : %s" % scene_path)
		await loading_screen.fade_from_black()
		loading_screen.queue_free()
		return

	var new_scene: PackedScene = ResourceLoader.load_threaded_get(scene_path)
	get_tree().change_scene_to_packed(new_scene)
	GameManager.change_state(GameManager.GameState.EXPLORATION)

	await get_tree().process_frame

	await loading_screen.fade_from_black()
	loading_screen.queue_free()
