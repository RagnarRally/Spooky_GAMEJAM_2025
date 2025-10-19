extends Node2D
class_name CosmicHorror

@export var target: Node2D

@export var chase_speed: float = 100
@export var chase_time_range: Vector2 = Vector2.ONE
@export var rest_time_range: Vector2 = Vector2.ONE

@export var screen_audio_player: AudioStreamPlayer

@export var speed_curve: Curve

enum {CHASING, RESTING}
var sm:= CSM.new({	
	CHASING: {CSM.ENTER: _chasing_enter, CSM.PROCESS: _chasing_process},
	RESTING: {CSM.ENTER: _resting_enter, CSM.PROCESS: _resting_process,}
})

var _current_chase_time = 0
var _current_rest_time = 0

var _close_to_target: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sm.switch(CHASING)
	pass # Replace with function body.

func _process(delta: float) -> void:
	sm.process(delta)

func _chasing_enter():
	_current_chase_time = randf_range(chase_time_range.x, chase_time_range.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _chasing_process(delta):

	_current_chase_time -= delta

	var target_dir = global_position.direction_to(target.global_position)
	var distance = global_position.distance_to(target.global_position)

	var distance_multplier 
	if distance > speed_curve.max_domain:
		distance_multplier = speed_curve.sample(speed_curve.max_domain)
	else:
		distance_multplier = speed_curve.sample(distance)

	if not _close_to_target and distance < 300:
		_close_to_target = true
		_close_to_target_activity()
	elif distance > 800:
		_close_to_target = false


	var chase_vector = target_dir * chase_speed * delta * distance_multplier

	print("Cosmic horror: speed=%0.02f, distance=%0.02f" % [chase_vector.length(), distance])
	
	global_translate(chase_vector)

	# if _current_chase_time <= 0:
	# 	sm.switch(RESTING)

func _resting_enter():
	_current_rest_time = randf_range(rest_time_range.x, rest_time_range.y)

func _resting_process(delta):

	_current_rest_time -= delta

	if _current_rest_time <= 0:
		sm.switch(CHASING)

func _close_to_target_activity():
	pass
