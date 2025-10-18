# Callable statemachine
Since we're talking state machines, let me just say that guys at Gdquest should do something about that tutorial. Although the implementation shown there does its job, it really pulls it off in a clunky overcomplicated way, using many things that should really not be in an introductory state machine tutorial for beginners. Among those are: dogmatic oo "everything is a class" approach, virtual calls, awaits/yields, misuse of node's owner property, parent node references, using strings for state identifiers... I could go on.

The biggest problem is that this tutorial is extremely popular. Every single beginner posting here about their problems with state machines copied that approach. Many people think that this is the way to do state management in Godot. On top of that, it's for 3.x and for some reason everybody does it in 4.x, leading to additional frustration.

With introduction of callables in 4.x, this type of state machine implementation becomes utterly obsolete. Note that even without callables a state machine can be implemented in much less convoluted way.

So here's my implementation of a simple state machine:

```
class_name SM

enum {ENTER, EXIT, PROCESS}
var states; var current

func _init(s):
	states = s

func switch(new):
	var old = current
	current = states[new] if states.has(new) else null
	if current != old:
		if old and old.has(EXIT): old[EXIT].call()
		if current and current.has(ENTER): current[ENTER].call()
	
func process(delta):
	if current and current.has(PROCESS): current[PROCESS].call(delta)
```

That's all there is to it. It can handle any number of states with 3 basic callbacks per state (enter, exit, process). The functionality can be easily extended. The state callbacks are held in a dictionary which can be indexed with any type of key we choose. The usage is simple as well:

extends Node

enum {IDLE, WALK}
var sm:= SM.new({	IDLE: {SM.PROCESS: _idle_process},
			WALK: {SM.PROCESS: _walk_process, SM.ENTER: _walk_enter, SM.EXIT: _walk_exit}})
func _ready():
	sm.switch(IDLE)

func _process(delta):
	sm.process(delta)

func _idle_process(delta): print("IDLE PROCESS")
func _walk_enter(): print("WALK ENTER")
func _walk_exit(): print("WALK EXIT")
func _walk_process(delta): print("WALK PROCESS")

Just initialize the SM object with a dictionary of state callbacks and call SM::process() each frame. Switch the state by calling SM::switch().

All that is left to do is writing actual state callbacks. Each of those can be placed in any script or even passed as lambda. In most cases the best place obviously is the script of an object whose state we're managing so all its properties are directly available.

There you have it. Only 15 lines of state machine class code, no additional nodes or convoluted setups, easily extended. Just instantiate the SM object, give it the callbacks and switch as needed.