extends Control

@onready var green_bar = $green
@onready var yellow_left = $yellow_left
@onready var yellow_right = $yellow_right
@onready var selector = $selector
@onready var player = $"../../RigidBody2D"

@export var selector_speed = 450
var selector_direction = 1

var moving = true

# green is 60 start + 29 per step up to 7 steps
# selector start position is 2 and end is 340

func _ready() -> void:
	randomize_areas()
	
func randomize_areas():
	green_bar.position.x = 60 + 29 * randi_range(1,7)
	yellow_left.position.x = green_bar.position.x - 29
	yellow_right.position.x = green_bar.position.x + 29
	
func _process(delta: float) -> void:
	if moving == true:
		selector.position.x += selector_speed * selector_direction * delta
		if selector.position.x > 340:
			selector_direction = -1
		elif selector.position.x < 2:
			selector_direction = 1
			
func reset_me():
	selector.position.x = 2
	moving = true

func _input(event: InputEvent) -> void:
	if (player.bursts):
		return
	if event.is_action_pressed("selector_stop"):
		moving = false
		if selector.position.x > green_bar.position.x - 10 and selector.position.x < green_bar.position.x + 35:
			await get_tree().create_timer(0.1).timeout
			player.bursts = 2
		elif selector.position.x > green_bar.position.x - 39 and selector.position.x < green_bar.position.x + 64:
			await get_tree().create_timer(0.1).timeout
			player.bursts = 1
		else: # FAIL     
			#print("FAIL")
			reset_me()
