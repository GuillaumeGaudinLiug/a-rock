extends Node

var player: AudioStreamPlayer
var current_stream: AudioStream


func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.bus = "Music"
	add_child(player)


func play_music(stream: AudioStream, fade_duration: float = 0.6) -> void:
	if stream == current_stream and player.playing:
		return  # déjà en train de jouer ce morceau : on ne relance rien

	current_stream = stream

	if stream == null:
		_fade_out(fade_duration)
		return

	if player.playing and fade_duration > 0.0:
		var tween := create_tween()
		tween.tween_property(player, "volume_db", -40.0, fade_duration)
		tween.tween_callback(func():
			player.stream = stream
			player.volume_db = 0.0
			player.play()
		)
	else:
		player.stream = stream
		player.volume_db = 0.0
		player.play()


func _fade_out(duration: float) -> void:
	if not player.playing:
		return
	var tween := create_tween()
	tween.tween_property(player, "volume_db", -40.0, duration)
	tween.tween_callback(player.stop)
