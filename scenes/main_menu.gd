extends Node2D

@export var play_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

	play_button.button_up.connect(_on_play_game)

func _on_play_game():
	SceneSwitcher.change_scene_to("intro")
