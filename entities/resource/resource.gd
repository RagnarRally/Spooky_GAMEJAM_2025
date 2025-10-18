extends Node


func _on_body_entered(body: Node2D) -> void:
	Globals.points += 1
	get_node("/root/Game/CanvasLayer/Label").text = "Points: " + str(Globals.points)
	$"..".queue_free()
