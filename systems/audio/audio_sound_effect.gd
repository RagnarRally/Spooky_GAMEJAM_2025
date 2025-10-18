extends AudioStreamPlayer
class_name AudioSoundEffect

var _destroy_on_complete: bool = true

func setup(audio: ConfigurableAudioStreamResource, destroy_on_complete: bool = true):

	stream = audio.stream
	pitch_scale = randf_range(audio.pitch_range.x, audio.pitch_range.y)
	volume_db = linear_to_db(audio.volume)

	if not audio.audio_bus.is_empty():
		bus = audio.audio_bus
	
	_destroy_on_complete = destroy_on_complete

	play()

func _on_finished() -> void:
	if _destroy_on_complete:
		queue_free()
