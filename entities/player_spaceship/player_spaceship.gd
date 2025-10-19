extends RigidBody2D
class_name PlayerSpacehip

signal died

@export var engine_power = 800
@export var spin_power = 10000
@export var minigame_offset = Vector2(-170,100)
#@export var scene : PackedScene
#@export var MiniGame : FuelMiniGame

@export var boost_sound: ConfigurableAudioStreamResource

@onready var health_component: HealthComponent = $HealthComponent
@onready var MiniGame = $minigame
@onready var camera = $Camera2D

@onready var drag_hint = $drag_hint
@onready var drag_hint_dot = $drag_hint/dot

const distance = 1000

var thrust = Vector2.ZERO
var rotation_dir = 0

# FOR FLICKING
var dragging = false
var mouse_pos: Vector2
var drag_hint_mouse: Vector2

#const removeTimeOut = 1.0
#var timeOut

#var spawned_objects = []

const MAX_DISTANCE = 2000

var bursts = 0

const MAXCOOLDOWN = 0.3

var coolDown = 0

func _ready() -> void:
	health_component.health_zero.connect(_on_health_zero)
	#timeOut = removeTimeOut
	#while true:
		#await get_tree().create_timer(2.0).timeout
		#var instance = scene.instantiate()
		#instance.position = Vector2(-transform.y * distance) + position
		#get_tree().current_scene.add_child(instance)
		#spawned_objects.append(instance)
		

func _physics_process(_delta : float):
	var desired_angle = linear_velocity.angle()
	rotation = lerp_angle(rotation, desired_angle, 2*_delta)
	
func _process(delta: float) -> void:
	if coolDown:
		coolDown -= delta
		if coolDown < 0.0:
			coolDown = 0.0
	
	Globals.timeTotal += delta
	
	# minigame follow
	MiniGame.position = position + minigame_offset
	#timeOut -= delta
	#if (timeOut < 0.0):
		#timeOut = removeTimeOut
		#remove_stuff()
	if dragging:
		drag_hint_mouse = get_global_mouse_position()
		drag_hint.visible = true
		drag_hint.position = position
		var rot_dir = drag_hint.global_position.direction_to(drag_hint_mouse)
		drag_hint.look_at(drag_hint.global_position - rot_dir)
		#if get_global_mouse_position().distance_to(screen_center) < drag_hint.global_position.distance_to(screen_center):
			#drag_hint_dot.global_position = mouse_pos
		#else:
			#drag_hint_dot.global_position = screen_center
		#drag_hint_dot.global_position = drag_hint_mouse
		#var dot_dir = drag_hint_mouse - global_position
		#drag_hint_dot.global_position = global_position + dot_dir.limit_length(250)
		var dot_dir = drag_hint_mouse - global_position
		var length = dot_dir.length()

		if length > 0:
			var clamped_length = clamp(length, 94, 250)
			drag_hint_dot.global_position = global_position + dot_dir.normalized() * clamped_length
		else:
			drag_hint_dot.global_position = global_position + Vector2.RIGHT * 94
	else:
		drag_hint.visible = false

func _input(event):
	#if event.is_action_pressed("thrust") and bursts:
		#apply_impulse(transform.x * engine_power, Vector2.ZERO)
		#bursts -= 1
		##print("Hi there")
		## $"../AudioStreamPlayer".play()
		#AudioManager.play_sound_effect(boost_sound)
		#if (!bursts):
			#MiniGame.reset_me()
			#MiniGame.randomize_areas()
			
	if event.is_action_pressed("left_mouse"):
		dragging = true
		mouse_pos = get_global_mouse_position()
		
	elif event.is_action_released("left_mouse"):
		if dragging:
			dragging = false
			var mouse_stop_pos = get_global_mouse_position()
			var drag_dir = mouse_pos.direction_to(mouse_stop_pos)
			if coolDown:
				return
			coolDown = MAXCOOLDOWN
			apply_impulse(-drag_dir * engine_power)
			AudioManager.play_sound_effect(boost_sound)
		
#func remove_stuff():
	#for obj in spawned_objects:
		#if obj.position.distance_to(position) > MAX_DISTANCE:
			#obj.queue_free()	
			#spawned_objects.erase(obj)

func _on_health_zero(attack):
	died.emit()
