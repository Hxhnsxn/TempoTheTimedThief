extends Area2D



func _on_body_entered(body):
	if body.name == "Player":
		body.enter_slow_zone()

func _on_body_exited(body):
	if body.name == "Player":
		body.exit_slow_zone()
