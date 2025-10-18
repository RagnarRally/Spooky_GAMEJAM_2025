extends Node2D
class_name CosmicHorror

@export var target: Node2D

enum {CHASING, RESTING}
var sm:= CSM.new({	
    CHASING: {CSM.ENTER: _chasing_enter, CSM.PROCESS: _chasing_process},
    RESTING: {CSM.ENTER: _resting_enter, CSM.PROCESS: _resting_process,}
})

var chase_time: float = 3
var rest_time: float = 3

var _current_chase_time = 0
var _current_rest_time = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _chasing_enter():
	_current_chase_time = chase_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _chasing_process(delta):

	_current_chase_time -= delta
	
	if _current_chase_time:
		sm.switch(RESTING)

func _resting_enter():
	_current_rest_time = rest_time

func _resting_process(delta):

	_current_rest_time -= delta

	if _current_chase_time <= 0:
		sm.switch(CHASING)

