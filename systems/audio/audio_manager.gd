extends Node2D

@export var music_tracks: Array[NamedAudioTrack] = []
@export var music_audio_player: AudioStreamPlayer
@export var sound_effect_scene: PackedScene
@export var sound_effect_scene_positional: PackedScene

var _music_dict: Dictionary = {}

var _music_tween: Tween = null

## 
func play_sound_effect(audio: ConfigurableAudioStreamResource, destroy_on_complete: bool = true):
	var new_node := sound_effect_scene.instantiate()
	add_child(new_node)
	new_node.setup(audio, destroy_on_complete)

func play_sound_effect_positional(audio: ConfigurableAudioStreamResource, sound_global_position: Vector2, destroy_on_complete: bool = true):
	var new_node := sound_effect_scene.instantiate()
	add_child(new_node)
	new_node.setup(audio, destroy_on_complete)
	new_node.global_position = sound_global_position

func change_music(track_name: String, fade_out_time: float = 0.5, fade_in_time: float = 0.5):

	if _music_tween:
		_music_tween.kill()

	var named_track = _music_dict[track_name] as NamedAudioTrack

	# TODO: Why is there issue using linear_to_db(...)?
	# Fade out if music is playing
	if music_audio_player.playing:
		_music_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		_music_tween.tween_method(_set_music_volume_linear, 1.0, 0.0, fade_out_time)
		# _music_tween.tween_property(music_audio_player, "volume_db", -80, fade_out_time)
		await _music_tween.finished
		
	# Switch to the new audio
	music_audio_player.stream = named_track.track
	music_audio_player.volume_db = -80

	# Fade in new track
	music_audio_player.play()
	_music_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	_music_tween.tween_method(_set_music_volume_linear, 0.0, 1.0, fade_in_time)
	# _music_tween.tween_property(music_audio_player, "volume_db", 0, fade_in_time)
	await _music_tween.finished


func _set_music_volume_linear(new_volume: float):
	music_audio_player.volume_db = linear_to_db(new_volume)
	
#region Private
func _ready() -> void:

	for named_track in music_tracks:
		_music_dict[named_track.identifier] = named_track

#endregion
