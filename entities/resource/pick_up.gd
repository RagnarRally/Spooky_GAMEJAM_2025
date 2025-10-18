extends Area2D

func _on_body_entered(body: Node2D) -> void:
	#print(body.name)
	#if body.name == "PlayerSpaceship":
		#print("Bonus point!")
	Globals.points += 1
	get_node("/root/Game/CanvasLayer/Label").text = "Points: " + str(Globals.points)
	$"../..".queue_free()
