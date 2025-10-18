extends Resource
class_name ConfigurableAudioStreamResource

#region Exports
@export var stream: AudioStream
@export_range(0.0, 1.0) var volume: float = 1
@export var pitch_range: Vector2 = Vector2.ONE

## The audio bus that the sound will play on. Must match a bus defined in the audio bus layout.
## Leave empty to not set the audio bus. 
@export var audio_bus: StringName = ""
#endregion