extends Area2D

# Reference to the AnimationPlayer child node.
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var small_loot: Array = [1, 5, 10, 20]
var basic_treasure = preload("res://assets/scenes/items and interactables/treasure/basic_treasure.tscn")

# Upon being attacked by the player,
# the jar enters its broken animation for 0.5 seconds
# and then disappears later.
func _on_area_entered(area: Area2D) -> void:
	animation_player.play("Broken")
	
	var loot_choice = small_loot.pick_random()
	var treasure_instance = basic_treasure.instantiate()
	
	treasure_instance.global_position = global_position
	get_parent().call_deferred("add_child", treasure_instance)
	treasure_instance.chestspawn = true
	treasure_instance.set_rarity(int(loot_choice))	
	await animation_player.animation_finished
	queue_free()
				
