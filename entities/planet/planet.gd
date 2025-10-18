extends Node2D
class_name Planet

@export var properties: PlanetProperties

@export var _graphics_root: Node2D
@export var collision_shape: CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	if properties:
		setup(properties)

func setup(new_properties: PlanetProperties):

	_graphics_root.scale = Vector2.ONE * new_properties.size / 10
	collision_shape.shape.radius = new_properties.size
	