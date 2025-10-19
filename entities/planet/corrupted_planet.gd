extends Node2D
class_name CorruptedPlanet

@export var properties: PlanetProperties

@export var _graphics_root: Node2D
@export var collision_shape: CollisionShape2D

@export var explosion_particles: GPUParticles2D
@export var anim_player: AnimationPlayer

@export var corrupted_area: Area2D
@export var corrupted_area_shape: CollisionShape2D
@export var corruption_sprite: Sprite2D

@export var explosion_sfx: ConfigurableAudioStreamResource

var _properties: PlanetProperties

enum {CORRUPTION_BEGIN, SPREADING}
var sm:= CSM.new({	
	CORRUPTION_BEGIN: {CSM.ENTER: _CORRUPTION_BEGIN_enter, CSM.PROCESS: _CORRUPTION_BEGIN_process},
	SPREADING:        {CSM.ENTER: _SPREADING_enter, CSM.PROCESS: _SPREADING_process,}
})

var _current_corruption_begin_time: float = 1.0
var _current_corruption_radius: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	if properties:
		setup(properties)

	sm.switch(CORRUPTION_BEGIN)

func setup(new_properties: PlanetProperties):

	_graphics_root.scale = Vector2.ONE * new_properties.size / 10
	collision_shape.shape.radius = new_properties.size

	var base_corrupt = new_properties.size*3+32

	_current_corruption_radius =  randf_range(base_corrupt, base_corrupt*4)

	_properties = new_properties
	_set_corruption_size(_current_corruption_radius)

func _process(delta: float) -> void:
	sm.process(delta)

func _on_area_2d_2_body_entered(body: Node2D) -> void:

	Globals.damage_player(1)

	# Globals.healthPoints -= 1
	# get_node("/root/Game/PlayerSpaceship/Camera2D").add_trauma(1.0)
	# get_node("/root/Game/CanvasLayer/HBoxContainer").get_child(Globals.healthPoints).texture = Globals.HEART_EMPTY
	# #get_node("/root/Game/CanvasLayer/Label").text = "HP: " + str(Globals.healthPoints)
	# if Globals.healthPoints <= 0:
	# 	Globals.Game_Over()

	explode_planet()
	
#func _process(delta: float) -> void:
	#print(Globals.healthPoints)

func explode_planet():
	AudioManager.play_sound_effect(explosion_sfx)
	anim_player.play("explode")
	await anim_player.animation_finished
	queue_free()


func _CORRUPTION_BEGIN_enter():
	pass

func _CORRUPTION_BEGIN_process(delta):
	_current_corruption_begin_time -= delta

	if _current_corruption_begin_time <= 0:
		sm.switch(SPREADING)

func _SPREADING_enter():
	pass

func _SPREADING_process(delta):

	_current_corruption_radius += 20 * delta 

	_set_corruption_size(_current_corruption_radius)

	
func _set_corruption_size(radius):
	corrupted_area_shape.shape.radius = radius
	corruption_sprite.scale = 2 * Vector2.ONE * radius / (corruption_sprite.texture.get_size().x)


func _on_corrupt_area_2d_body_entered(body: Node2D) -> void:
	Globals.player_entered_corrupted_planet.emit(self)


func _on_corrupt_area_2d_body_exited(body: Node2D) -> void:
	Globals.player_exited_corrupted_planet.emit(self)
