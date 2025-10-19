extends Node2D

@export var buttonAngry: Button
@export var buttonBlaming: Button
@export var buttonEmpathy: Button
@export var buttonLoving: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttonAngry.button_up.connect(_option_pressed.bind("Angry"))
	buttonBlaming.button_up.connect(_option_pressed.bind("Blaming"))
	buttonEmpathy.button_up.connect(_option_pressed.bind("Empathy"))
	buttonLoving.button_up.connect(_option_pressed.bind("Loving"))
	$CanvasLayer/TimeText.text = "TIME\n%.02f" % Globals.timeTotal
	var tween = create_tween()
	tween.tween_property($CanvasLayer/HBoxContainer, "modulate", Color.WHITE, 3.0)
	tween.tween_property($CanvasLayer/AnswerHer, "modulate", Color.WHITE, 1.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _option_pressed(option: String):
	
	if option == "Angry":
		$CanvasLayer/HBoxContainer/Angry.text = "Your dead!"
		#get_tree().quit()
	if option == "Blaming":
		$CanvasLayer/HBoxContainer/Blaming.text = "I hate you!"
		#get_tree().quit()
	if option == "Empathy":
		$CanvasLayer/HBoxContainer/Empathic.text = "Death to the galaxy!"
	if option == "Loving":
		$CanvasLayer/HBoxContainer/Loving.text = "I will kill you pervert!"
	await get_tree().create_timer(3.0).timeout
	SceneSwitcher.change_scene_to("game")
