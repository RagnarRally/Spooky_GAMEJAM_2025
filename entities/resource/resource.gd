extends Node

var hasEntered = false

@export var health_sound: ConfigurableAudioStreamResource

func _on_body_entered(body: Node2D) -> void:
	if hasEntered:
		return
	hasEntered = true
	if (Globals.healthPoints < 3):
		get_node("/root/Game/CanvasLayer/HBoxContainer").get_child(Globals.healthPoints).texture = Globals.HEART_FULL
		Globals.healthPoints += 1
	var tween = create_tween()
	tween.tween_property($Node2D, 'modulate', Color(0.0, 0.0, 0.0, 0.0), 0.5)
	AudioManager.play_sound_effect(health_sound)
	await tween.finished
	queue_free()
