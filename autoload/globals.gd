extends Node

signal player_entered_corrupted_planet(corrupted_planet)
signal player_exited_corrupted_planet(corrupted_planet)

signal player_damaged()

const MAX_HP = 3
var healthPoints = MAX_HP
var timeTotal = 0.0

const HEART_FULL = preload("res://assets/art/Objects/Collectible_Heart.png")
const HEART_EMPTY = preload("res://assets/art/Objects/Heart_Empty.png")

func Game_Over():
	SceneSwitcher.change_scene_to("game_over") 

func damage_player(amount):
	healthPoints -= amount
	player_damaged.emit()

	if healthPoints <= 0:
		Game_Over()

func reset_for_new_run():
	healthPoints = MAX_HP
	timeTotal = 0

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
