extends Node2D

@export var player_spaceship: PlayerSpaceship
@export var camera: Camera2D

var zoomed: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	player_spaceship.died.connect(_on_player_died)

	pass
	# AudioManager.change_music("game_music")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug1"):
		pass
	if event.is_action_pressed("debug2"):
		camera.zoom = Vector2.ONE if zoomed else Vector2.ONE*0.2
		zoomed = not zoomed
	if event.is_action_released("escape"):
		SceneSwitcher.change_scene_to("main_menu")
	if event.is_action_released("restart"):
		get_tree().reload_current_scene()

func _on_player_died():
	_reset.call_deferred()

func _reset():
	SceneSwitcher.change_scene_to("game_over")
