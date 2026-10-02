extends Node2D
class_name KeyObstacle

@onready var animation_player: AnimationPlayer = $AnimationPlayer



func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# If the player has at least one key, call open.
		pass

func open() -> void:
	animation_player.play("Open")
	await animation_player.animation_finished
	queue_free()
