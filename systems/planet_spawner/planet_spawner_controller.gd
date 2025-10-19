extends Node2D
class_name PlanetSpawnerController

@export var planet_packed: PackedScene
@export var corrupted_planet_packed: PackedScene
@export var resource_packed: PackedScene
@export var special_planet_packed: PackedScene
@export var player: RigidBody2D
@export var special_planets_container: Node2D

@export var spawn_range: float = 1000
@export var spawn_interval: Vector2 = Vector2(1,2)
@export var spawn_interval_resource: Vector2 = Vector2(4,6)
@export var spawn_interval_special_planet: Vector2 = Vector2(3,6)
@export var spawn_special_planets: bool = false
@export var spawn_spread_deg: float = 30
@export var min_distance_between_planets: float = 400
@export var min_distance_between_planetsandresources: float = 200

var _spawned_planets: Array
var _spawned_resources = []
var _spawned_special_planets = []

var _current_spawn_time: float = 0
var _current_spawn_time_resource: float = 0
var _current_spawn_time_special_planet: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#spawn_planets()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	_current_spawn_time -= delta

	if _current_spawn_time <= 0:
		var did_spawn_planet = spawn_planet()
		#print("Spawned planet: " + str(did_spawn_planet))
		_current_spawn_time = randf_range(spawn_interval.x, spawn_interval.y)
		
	_current_spawn_time_resource -= delta

	if _current_spawn_time_resource <= 0:
		var did_spawn_planet = spawn_resource()
		#print("Spawned planet: " + str(did_spawn_planet))
		_current_spawn_time_resource = randf_range(spawn_interval_resource.x, spawn_interval_resource.y)

	_current_spawn_time_special_planet -= delta
	if _current_spawn_time_special_planet <= 0 and spawn_special_planets:
		spawn_special_planet()
		_current_spawn_time_special_planet = randf_range(spawn_interval_special_planet.x, spawn_interval_special_planet.y)
	queue_redraw()

func spawn_special_planet():
	var player_direction = player.linear_velocity.normalized()
	var player_direction_angle = player.linear_velocity.angle()

	var desired_position
	var valid_planets = []

	for p in _spawned_special_planets:
		if !is_instance_valid(p):
			continue
		var d = p.global_position.distance_squared_to(player.global_position)
		if d > pow(2000, 2):
			p.queue_free()
		valid_planets.append(p)

	_spawned_special_planets = valid_planets

	if len(_spawned_special_planets) > 3:
		return

	var angle_rad = randf_range(player_direction_angle-deg_to_rad(spawn_spread_deg), player_direction_angle+deg_to_rad(spawn_spread_deg)) 
	desired_position = player.global_position + Vector2.RIGHT.rotated(angle_rad) * (spawn_range+300)

	var planet_instance = special_planet_packed.instantiate()
	special_planets_container.add_child(planet_instance)
	planet_instance.global_position = desired_position
	_spawned_special_planets.append(planet_instance)



func _valid_planet_placement(new_planet_pos):
	for p in _spawned_planets:
		if !is_instance_valid(p):
			continue
		var d = p.global_position.distance_squared_to(new_planet_pos)
		if d > pow(6000, 2):
			p.queue_free()
		if d < pow(min_distance_between_planets, 2):
			return false
	return true
	
func _valid_resource_placement(new_resource_pos):
	for p in _spawned_planets: #Keep distance from planets
		if !is_instance_valid(p):
			continue
		var d = p.global_position.distance_squared_to(new_resource_pos)
		if d < pow(min_distance_between_planetsandresources, 2):
			return false
	return true

func spawn_planet():

	var player_direction = player.linear_velocity.normalized()
	var player_direction_angle = player.linear_velocity.angle()

	var desired_position
	var size
	var dist
	var is_corrupted

	var valid_placement_found = false

	for i in range(3): # make three attempts
		var angle_rad = randf_range(player_direction_angle-deg_to_rad(spawn_spread_deg), player_direction_angle+deg_to_rad(spawn_spread_deg)) 
		dist = randf_range(spawn_range, spawn_range + 500) #randf_range(100, 300)
		size = randf_range(10, 32)
		is_corrupted = randf() > 0.5

		desired_position = player.global_position + Vector2.RIGHT.rotated(angle_rad) * dist

		if _valid_planet_placement(desired_position):
			valid_placement_found = true
			break

	if not valid_placement_found:
		return false 

	var properties = PlanetProperties.new()
	properties.size = size
	properties.type = PlanetProperties.PlanetType.CORRUPTED if is_corrupted else PlanetProperties.PlanetType.NORMAL

	var planet_instance
	if is_corrupted:
		planet_instance = corrupted_planet_packed.instantiate() as CorruptedPlanet
	else:
		planet_instance = planet_packed.instantiate() as Planet
	add_child(planet_instance)
	planet_instance.global_position = desired_position
	planet_instance.setup(properties)

	_spawned_planets.append(planet_instance)

	return true

func spawn_resource():
				
	var player_direction = player.linear_velocity.normalized()
	var player_direction_angle = player.linear_velocity.angle()

	var desired_position
	var size
	var dist

	var valid_placement_found = false

	for i in range(3): # make three attempts
		var angle_rad = randf_range(player_direction_angle-deg_to_rad(spawn_spread_deg), player_direction_angle+deg_to_rad(spawn_spread_deg)) 
		dist = spawn_range #randf_range(100, 300)
		size = randf_range(10, 32)

		desired_position = player.global_position + Vector2.RIGHT.rotated(angle_rad) * dist

		if _valid_resource_placement(desired_position):
			valid_placement_found = true
			break

	if not valid_placement_found:
		return false 

	var resource_instance = resource_packed.instantiate()
	add_child(resource_instance)
	resource_instance.global_position = desired_position

	_spawned_resources.append(resource_instance)

	return true

func spawn_planets():


	# Clear existing
	for planet in _spawned_planets:
		if is_instance_valid(planet) and not planet.is_queued_for_deletion():
		
			planet.queue_free()

	var current_player_pos = player.global_position

	var planets_to_spawn = 10

	for i in range(planets_to_spawn):

		var angle = (float(i) / planets_to_spawn) * 2 * PI
		var dist = randf_range(100, 300)
		var size = randf_range(10, 64)

		var properties = PlanetProperties.new()
		properties.size = size

		var planet_instance = planet_packed.instantiate() as Planet
		add_child(planet_instance)
		planet_instance.global_position = current_player_pos + Vector2.LEFT.rotated(angle) * dist
		planet_instance.setup(properties)

		_spawned_planets.append(planet_instance)
		
		


func _draw() -> void:

	draw_circle(to_local(player.global_position), spawn_range, Color.BLUE, false)
