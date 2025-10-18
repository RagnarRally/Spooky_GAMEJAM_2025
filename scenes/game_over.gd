extends Node2D

@export var left_option_button: Button
@export var right_option_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	left_option_button.button_up.connect(_option_pressed.bind("left"))
	right_option_button.button_up.connect(_option_pressed.bind("right"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _option_pressed(option: String):
	
	if option == "left":
		pass
	if option == "right":
		pass
	
	SceneSwitcher.change_scene_to("game")
