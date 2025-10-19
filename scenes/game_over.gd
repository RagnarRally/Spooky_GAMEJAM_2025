extends Node2D

@export var buttonAngry: Button
@export var buttonBlaming: Button
@export var buttonEmpathy: Button
@export var buttonLoving: Button
var onePress = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttonAngry.button_up.connect(_option_pressed.bind("Angry"))
	buttonBlaming.button_up.connect(_option_pressed.bind("Blaming"))
	buttonEmpathy.button_up.connect(_option_pressed.bind("Empathy"))
	buttonLoving.button_up.connect(_option_pressed.bind("Loving"))
	$CanvasLayer/TimeText.text = "TIME\n%.02f" % Globals.timeTotal
	var tween = create_tween()
	tween.tween_property($CanvasLayer/VBoxContainer2, "modulate", Color.WHITE, 3.0)
	tween.tween_property($CanvasLayer/AnswerHer, "modulate", Color.WHITE, 1.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _option_pressed(option: String):
	if onePress:
		return
	onePress = true
	if option == "Angry":
		$CanvasLayer/DemonicVoice.text = "You are dead!"
		#get_tree().quit()
	if option == "Blaming":
		$CanvasLayer/DemonicVoice.text = "I hate you!"
		#get_tree().quit()
	if option == "Empathy":
		$CanvasLayer/DemonicVoice.text = "Death to the galaxy!"
	if option == "Loving":
		$CanvasLayer/DemonicVoice.text = "I will kill you pervert!"
	$CanvasLayer/DemonicVoice.add_theme_color_override("font_color", Color.BLACK)
	await get_tree().create_timer(3.0).timeout
	SceneSwitcher.change_scene_to("game")
