extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		TransitionScene.transition()
		await TransitionScene.on_transition_finished
		body.position = $Marker2D.global_position
