extends Node2D
class_name KeyObstacle

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var interacting: bool = true

func _ready() -> void:
	$InteractArrow.visible = false

# If the player interacts with the key obstacle and they have
# at least one key to open the door with, unlock and remove the obstacle.
func _process(delta: float) -> void:
	if (
		interacting
		and Input.is_action_just_pressed("interact")
		):
			$InteractArrow.visible = false
			open()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$InteractArrow.visible = true
		interacting = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		$InteractArrow.visible = false
		interacting = false

func open() -> void:
	animation_player.play("Open")
	await animation_player.animation_finished
	queue_free()
