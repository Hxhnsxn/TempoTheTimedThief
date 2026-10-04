extends Node2D

# Reference to the AnimationPlayer child node.
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Upon being attacked by the player,
# the block enters its broken animation for 0.5 seconds
# and then disappears later.
func _on_check_for_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Attack" or area.name == "DiveKick":
		if area.name == "DiveKick":
			area.get_parent().dive_bounce()
		animation_player.play("Broken")
		await animation_player.animation_finished
		queue_free()
