extends RigidBody2D

@export var engine_power = 800
@export var spin_power = 10000

var thrust = Vector2.ZERO
var rotation_dir = 0

const burstTimeOut = 1.0
var timeOut

func _ready() -> void:
	timeOut = burstTimeOut

func _physics_process(delta):
	thrust = Vector2.ZERO
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	constant_torque = rotation_dir * spin_power
	timeOut -= delta
	if (timeOut < 0.0):
		apply_impulse(-transform.y * engine_power, Vector2.ZERO)
		timeOut = burstTimeOut
