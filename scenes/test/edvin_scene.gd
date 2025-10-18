extends Node2D

@export var planet_spawner: PlanetSpawnerController
@export var player_spaceship: EPlayerSpaceship
@export var camera: Camera2D

var zoomed: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:

	if event.is_action_pressed("debug1"):
		planet_spawner.spawn_planets()
	if event.is_action_pressed("debug2"):
		camera.zoom = Vector2.ONE if zoomed else Vector2.ONE*0.2
		zoomed = not zoomed

# func _draw() -> void:

# 	draw_line(to_local(player_spaceship.global_position
