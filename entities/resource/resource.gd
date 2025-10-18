extends Node

func _on_body_entered(body: Node2D) -> void:
	if (Globals.healthPoints < 3):
		get_node("/root/Game/CanvasLayer/HBoxContainer").get_child(Globals.healthPoints).texture = Globals.HEART_FULL
		Globals.healthPoints += 1
		queue_free()
