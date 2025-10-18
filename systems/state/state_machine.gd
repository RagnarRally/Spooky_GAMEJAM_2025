class_name CSM
## Simple callable based state machine.
## Use like:
## enum {IDLE, WALK}
## var sm:= SM.new({	
##     IDLE: {SM.PROCESS: _idle_process},
##     WALK: {SM.PROCESS: _walk_process, SM.ENTER: _walk_enter, SM.EXIT: _walk_exit}
## })
signal state_switched

enum {ENTER, EXIT, PROCESS, PHYSICS_PROCESS, UNHANDLED_INPUT}

var states
var _current_state
var _enable_debug
var _current_state_enum

## Initialize the state machine states
func _init(defined_states, debug: bool = false) -> void:
	states = defined_states
	_enable_debug = debug

## Get the current state.
func get_current_state():
	return _current_state_enum

## Switch to another state. If exit/enter callables are defined they will be called.
func switch(new):
	var old = _current_state
	_current_state = states[new] if states.has(new) else null
	_current_state_enum = new
	if _enable_debug:
		print('SM: Switched to %s' % [new])
	if _current_state != old:
		if old and old.has(EXIT): old[EXIT].call()
		if _current_state and _current_state.has(ENTER): _current_state[ENTER].call()
	state_switched.emit(new)

func process(delta):
	if _current_state and _current_state.has(PROCESS): _current_state[PROCESS].call(delta)

func physics_process(delta):
	if _current_state and _current_state.has(PHYSICS_PROCESS): _current_state[PHYSICS_PROCESS].call(delta)

func unhandled_input(event: InputEvent):
	if _current_state and _current_state.has(UNHANDLED_INPUT): _current_state[UNHANDLED_INPUT].call(event)
