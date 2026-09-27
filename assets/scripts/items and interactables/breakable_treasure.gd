extends Area2D

# Reference to the AnimationPlayer child node.
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Upon being attacked by the player,
# the jar enters its broken animation for 0.5 seconds
# and then disappears later.
func _on_area_entered(area: Area2D) -> void:
	animation_player.play("Broken")
	await animation_player.animation_finished
	queue_free()


func _on_damage_area_3_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.


func _on_damage_area_3_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.
