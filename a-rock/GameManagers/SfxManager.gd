extends Node

const POOL_SIZE := 8

var players: Array[AudioStreamPlayer] = []
var next_index: int = 0


func _ready() -> void:
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		players.append(player)


func play(stream: AudioStream) -> void:
	if stream == null:
		print("SOund to play : " + stream.resource_name)
		return

	var player := players[next_index]
	next_index = (next_index + 1) % players.size()

	player.stream = stream
	player.play()
