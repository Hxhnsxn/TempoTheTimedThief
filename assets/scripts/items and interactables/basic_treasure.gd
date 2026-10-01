extends CharacterBody2D
class_name BasicTreasure


# Gravity.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# Variable for AnimatedSprite2D.
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Variable to indicate whether or not the treasure spawned
# from opening a chest.
@onready var chestspawn: bool = false
@onready var spawning: bool
@export var static_rarity: int 

# HUD
@onready var hud: Control = $"../../../CanvasLayer/HUD"



# This function is called by open_treasure, which is attached to
# treasure chests. It changes the rarity of the treasure and changes
# the appearance of the treasure accordingly.
# This function IS NOT called for determining the rarity of static
# treasure.
func set_rarity(rarity: int) -> void:
	if rarity == 1:
		$AnimatedSprite2D.frame = 0
	elif rarity == 5:
		$AnimatedSprite2D.frame = 1
	elif rarity == 10:
		$AnimatedSprite2D.frame = 2
	elif rarity == 20:
		$AnimatedSprite2D.frame = 3
	elif rarity == 50:
		$AnimatedSprite2D.frame = 4
	elif rarity == 100:
		$AnimatedSprite2D.frame = 5
		
# The rarity of static treasure is determined by the static_rarity
# export variable, so it can be set outside of the script.
# Set this to 1, 5, 10, 20, 50 or 100 ONLY!
func _ready() -> void:
	spawning = true
	if static_rarity == 1:
		$AnimatedSprite2D.frame = 0
	elif static_rarity == 5:
		$AnimatedSprite2D.frame = 1
	elif static_rarity == 10:
		$AnimatedSprite2D.frame = 2
	elif static_rarity == 20:
		$AnimatedSprite2D.frame = 3
	elif static_rarity == 50:
		$AnimatedSprite2D.frame = 4
	elif static_rarity == 100:
		$AnimatedSprite2D.frame = 5

# Some treasure will be placed floating around the level and shouldn't be
# affected by gravity.
# This makes the distinction between chest-spawned treasure
# and floating treasure.
func _physics_process(delta: float) -> void:
	# For chestspawn.
	if chestspawn == true:
		print("CHEST SPAWN")
	#if not is_on_floor() and spawning == true:
		#velocity.y = -5
		#velocity.x = randf_range(-15, 15)
		#spawning = false
	#if not is_on_floor() and spawning == false:
		#velocity.y += gravity / 400
	move_and_slide()

# Upon the player colliding with treasure, increase the player's
# in-level treasure count accordingly, then remove the treasure.
func _on_pick_up_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if $AnimatedSprite2D.frame == 0:
			hud.temp_treasure += 1
			print("+1 treasure")
		elif $AnimatedSprite2D.frame == 1:
			hud.temp_treasure += 5
			print("+5 treasure")
		elif $AnimatedSprite2D.frame == 2:
			hud.temp_treasure += 10
			print("+10 treasure")
		elif $AnimatedSprite2D.frame == 3:
			hud.temp_treasure += 20
			print("+20 treasure")
		elif $AnimatedSprite2D.frame == 4:
			hud.temp_treasure += 50
			print("+50 treasure")
		elif $AnimatedSprite2D.frame == 5:
			hud.temp_treasure += 100
			print("+100 treasure")
		queue_free()
