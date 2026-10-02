extends CharacterBody2D

@export var speed = 100

var direction: float

func _physics_process(delta: float) -> void:
	velocity = Vector2(0, speed)
	move_and_slide()

func _on_normal_collision_box_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is not SandShifter:
		queue_free()
