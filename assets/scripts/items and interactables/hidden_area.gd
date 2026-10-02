extends Area2D

var parent: TileMapLayer
var tween: Tween

func _ready() -> void:
	parent = self.get_parent()

# When entering/exiting a hidden area,
# we use a tween to smooth the modulation process.
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if tween and tween.is_running():
			tween.kill()
		if parent:
			tween = parent.create_tween()
			# Parent = target, modulate alpha = process,
			# 0 = value of alpha (make transparent),
			# 0.25 = time the tween will take
			tween.tween_property(parent, "modulate:a", 0, 0.25)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		if tween and tween.is_running():
			tween.kill()
		if parent:
			tween = parent.create_tween()
			tween.tween_property(parent, "modulate:a", 1, 0.25)
