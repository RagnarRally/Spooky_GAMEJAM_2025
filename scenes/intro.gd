extends Node2D

@export var contine_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contine_button.button_up.connect(_on_continue_button)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_continue_button():
	SceneSwitcher.change_scene_to("game")