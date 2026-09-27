class_name damageArea
extends Area2D

@export var damage: int = 10
@export var knock_force: float = 1000.0

func _init() -> void:
	collision_layer = 1 << 3 #basically layer 4
	collision_mask = 0
