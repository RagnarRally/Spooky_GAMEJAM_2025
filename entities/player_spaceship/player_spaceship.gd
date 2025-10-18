extends RigidBody2D

@export var engine_power = 800
@export var spin_power = 10000
#@export var scene : PackedScene
@export var MiniGame : FuelMiniGame

const distance = 1000

var thrust = Vector2.ZERO
var rotation_dir = 0

#const removeTimeOut = 1.0
#var timeOut

#var spawned_objects = []

const MAX_DISTANCE = 2000

var bursts = 0

#func _ready() -> void:
	#timeOut = removeTimeOut
	#while true:
		#await get_tree().create_timer(2.0).timeout
		#var instance = scene.instantiate()
		#instance.position = Vector2(-transform.y * distance) + position
		#get_tree().current_scene.add_child(instance)
		#spawned_objects.append(instance)
		

func _physics_process(_delta : float):
	thrust = Vector2.ZERO
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	constant_torque = rotation_dir * spin_power
	
#func _process(delta: float) -> void:
	#timeOut -= delta
	#if (timeOut < 0.0):
		#timeOut = removeTimeOut
		#remove_stuff()

func _input(event):
	if event.is_action_pressed("thrust") and bursts:
		apply_impulse(transform.x * engine_power, Vector2.ZERO)
		bursts -= 1
		#print("Hi there")
		$"../AudioStreamPlayer".play()
		if (!bursts):
			MiniGame.reset_me()
			MiniGame.randomize_areas()
		
#func remove_stuff():
	#for obj in spawned_objects:
		#if obj.position.distance_to(position) > MAX_DISTANCE:
			#obj.queue_free()	
			#spawned_objects.erase(obj)
