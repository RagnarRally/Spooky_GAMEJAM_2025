extends RigidBody2D

@export var engine_power = 800
@export var spin_power = 10000

var thrust = Vector2.ZERO
var rotation_dir = 0

func _physics_process(delta):
	thrust = Vector2.ZERO
	if (Input.is_action_pressed("thrust")):
		thrust = transform.x * engine_power
	rotation_dir = Input.get_axis("ui_left", "ui_right")
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
