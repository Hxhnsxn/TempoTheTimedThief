extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		print("Entered slow zone.")
		body.enter_slow_zone()

func _on_body_exited(body):
	if body.name == "Player":
		print("Exited slow zone.")
		body.exit_slow_zone()
