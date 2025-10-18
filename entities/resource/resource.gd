extends Node


func _on_body_entered(body: Node2D) -> void:
	if (Globals.healthPoints < 3):
		Globals.healthPoints += 1
		get_node("/root/Game/CanvasLayer/Label").text = "HP: " + str(Globals.healthPoints)
	$"..".queue_free()
