extends Node2D
class_name Planet

@export var properties: PlanetProperties

@export var _graphics_root: Node2D
@export var collision_shape: CollisionShape2D

@export var explosion_particles: GPUParticles2D
@export var anim_player: AnimationPlayer

@export var explosion_sfx: ConfigurableAudioStreamResource

var _properties: PlanetProperties

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	if properties:
		setup(properties)

func setup(new_properties: PlanetProperties):

	_graphics_root.scale = Vector2.ONE * new_properties.size / 10
	collision_shape.shape.radius = new_properties.size

	_properties = new_properties


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
