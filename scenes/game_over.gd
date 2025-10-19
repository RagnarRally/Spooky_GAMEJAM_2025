extends Node2D

@export var button1: Button
@export var button2: Button
@export var button3: Button
@export var button4: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button1.button_up.connect(_option_pressed.bind("1"))
	button2.button_up.connect(_option_pressed.bind("2"))
	button3.button_up.connect(_option_pressed.bind("3"))
	button4.button_up.connect(_option_pressed.bind("4"))
	$CanvasLayer/Label.text = "TIME\n%.02f" % Globals.timeTotal


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _option_pressed(option: String):
	
	if option == "1":
		pass
	if option == "2":
		pass
	if option == "3":
		pass
	if option == "4":
		pass
	
	SceneSwitcher.change_scene_to("game")
