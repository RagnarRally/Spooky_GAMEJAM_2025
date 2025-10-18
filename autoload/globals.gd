extends Node

const MAX_HP = 3
var healthPoints = MAX_HP

func Game_Over():
	SceneSwitcher.change_scene_to("game_over") 
	healthPoints = MAX_HP

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
