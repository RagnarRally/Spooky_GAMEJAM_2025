extends Node2D
class_name Planet

@export var properties: PlanetProperties

@export var _graphics_root: Node2D
@export var collision_shape: CollisionShape2D

@export var explosion_particles: GPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	if properties:
		setup(properties)

func setup(new_properties: PlanetProperties):

	_graphics_root.scale = Vector2.ONE * new_properties.size / 10
	collision_shape.shape.radius = new_properties.size

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	Globals.healthPoints -= 1
	get_node("/root/Game/CanvasLayer/Label").text = "HP: " + str(Globals.healthPoints)
	if Globals.healthPoints <= 0:
		SceneSwitcher.change_scene_to("game_over") 

	explosion_particles.emitting = true
	await get_tree().create_timer(1).timeout
	queue_free()
