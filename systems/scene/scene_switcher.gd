extends Node2D

enum SceneName { MAIN_MENU, GAME, UNSET }

@export var defined_scenes: Array[SceneSwitcherEntryRes] = []

@export var animation_player: AnimationPlayer
@export var color_rect: ColorRect

var _current_scene_name: String = ""
var _defined_scenes_map: Dictionary[String, SceneSwitcherEntryRes] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.hide()
	for entry in defined_scenes:
		_defined_scenes_map[entry.scene_name] = entry


func change_scene_to(scene_name: String):
	printraw("Changing scene to " + str(scene_name) + " ...")
	var _scene_entry = _defined_scenes_map[scene_name]
	animation_player.play("fade_in")
	color_rect.show()
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(_scene_entry.scene_packed)
	animation_player.play("fade_out")
	await animation_player.animation_finished
	color_rect.hide()
	_current_scene_name = scene_name
	print(" finished loading new scene.")
