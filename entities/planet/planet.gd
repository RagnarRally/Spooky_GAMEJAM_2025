extends Node2D
class_name Planet

@export var properties: PlanetProperties

@export var _graphics_root: Node2D
@export var collision_shape: CollisionShape2D

@export var explosion_particles: GPUParticles2D
@export var anim_player: AnimationPlayer

@export var corrupted_area: Area2D


var _properties: PlanetProperties



# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	if properties:
		setup(properties)

func setup(new_properties: PlanetProperties):

	_graphics_root.scale = Vector2.ONE * new_properties.size / 10
	collision_shape.shape.radius = new_properties.size

	_properties = new_properties

	corrupted_area.monitoring = _properties.type == PlanetProperties.PlanetType.CORRUPTED
	corrupted_area.visible = _properties.type == PlanetProperties.PlanetType.CORRUPTED

func _process(delta: float) -> void:

	if _properties.type == PlanetProperties.PlanetType.CORRUPTED:
		pass

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	Globals.healthPoints -= 1
	get_node("/root/Game/CanvasLayer/Label").text = "HP: " + str(Globals.healthPoints)
	if Globals.healthPoints <= 0:
		SceneSwitcher.change_scene_to("game_over") 

	explode_planet()

func explode_planet():
	anim_player.play("explode")
	await anim_player.animation_finished
	queue_free()
