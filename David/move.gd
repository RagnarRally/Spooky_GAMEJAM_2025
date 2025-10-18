extends RigidBody2D

@export var engine_power = 800
@export var spin_power = 10000
@export var scene : PackedScene

const distance = 1000

var thrust = Vector2.ZERO
var rotation_dir = 0

const burstTimeOut = 1.0
var timeOut

var spawned_objects = []

const MAX_DISTANCE = 2000

func _ready() -> void:
	timeOut = burstTimeOut
	while true:
		await get_tree().create_timer(2.0).timeout
		var instance = scene.instantiate()
		instance.position = Vector2(-transform.y * distance) + position
		get_tree().current_scene.add_child(instance)
		spawned_objects.append(instance)

func _physics_process(delta):
	thrust = Vector2.ZERO
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	constant_torque = rotation_dir * spin_power
	timeOut -= delta
	if (timeOut < 0.0):
		apply_impulse(-transform.y * engine_power, Vector2.ZERO)
		timeOut = burstTimeOut
		remove_stuff()
		
func remove_stuff():
	for obj in spawned_objects:
		if obj.position.distance_to(position) > MAX_DISTANCE:
			obj.queue_free()	
			spawned_objects.erase(obj)
