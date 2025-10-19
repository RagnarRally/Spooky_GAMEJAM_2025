extends Node2D

@export var player_spaceship: PlayerSpacehip
@export var cosmic_horror_entity: CosmicHorror
@export var camera: Camera2D
@export var health_container: HBoxContainer
@export var damage_indicator: TextureRect

@export_subgroup("Corrupt planet things")
@export var corruption_time_limit: float = 3

var zoomed: bool = true

var _current_corrupted_planets_within_range_of_player: Array
var _current_corruption_time: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	player_spaceship.died.connect(_on_player_died)

	Globals.player_entered_corrupted_planet.connect(_player_entered_corrupted_planet)
	Globals.player_exited_corrupted_planet.connect(_player_exited_corrupted_planet)
	Globals.player_damaged.connect(_player_damaged)

	damage_indicator.visible = true

	Globals.reset_for_new_run()

	damage_indicator.modulate.a = 0

	# AudioManager.change_music("game_music")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	var target_damage_indicator_alpha_corruption = 0
	var target_damage_indicator_alpha_cosmic_horror = 0
	
	if len(_current_corrupted_planets_within_range_of_player) > 0:
		_current_corruption_time += delta
		target_damage_indicator_alpha_corruption = clampf(_current_corruption_time / corruption_time_limit, 0, 1)
	else:
		target_damage_indicator_alpha_corruption = 0
		_current_corruption_time = 0

	
	var d = cosmic_horror_entity.global_position.distance_to(player_spaceship.global_position)
	if d < 300:
		target_damage_indicator_alpha_cosmic_horror = (300 - d)/300
	else:
		target_damage_indicator_alpha_cosmic_horror = 0

		#damage_indicator.modulate.a = 0

	var a = max(target_damage_indicator_alpha_corruption, target_damage_indicator_alpha_cosmic_horror)

	if a > 0:
		damage_indicator.modulate.a = lerpf(damage_indicator.modulate.a, a, 100*delta)
	else:
		damage_indicator.modulate.a = lerpf(damage_indicator.modulate.a, 0, 10*delta)

	if _current_corruption_time >= corruption_time_limit:
		# TODO: damage the player
		Globals.damage_player(1)
		_current_corruption_time = 0



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
	Globals.Game_Over()

func _player_entered_corrupted_planet(corrupted_planet):
	_current_corrupted_planets_within_range_of_player.append(corrupted_planet)

func _player_exited_corrupted_planet(corrupted_planet):
	_current_corrupted_planets_within_range_of_player.erase(corrupted_planet)

func _player_damaged():

	camera.add_trauma(1.0)
	health_container.get_child(Globals.healthPoints).texture = Globals.HEART_EMPTY
	pass
