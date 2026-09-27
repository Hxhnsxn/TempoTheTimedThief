extends Node2D

const SPEED: int = 60
var direction: int = -1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right_down: RayCast2D = $RayCastRightDown
@onready var ray_cast_left_down: RayCast2D = $RayCastLeftDown
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	checkWallRaycasts()
	checkGroundRaycasts()
	
	position.x += direction * SPEED * delta
	
func checkWallRaycasts() -> void:
	if ray_cast_left.is_colliding() and ray_cast_right.is_colliding():
		direction = 0
	elif ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = false
	elif ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = true
	
func checkGroundRaycasts() -> void:
	if not ray_cast_left_down.is_colliding() and not ray_cast_right_down.is_colliding():
		direction = 0
	elif not ray_cast_right_down.is_colliding():
		direction = -1
		animated_sprite.flip_h = false
	elif not ray_cast_left_down.is_colliding():
		direction = 1
		animated_sprite.flip_h = true
