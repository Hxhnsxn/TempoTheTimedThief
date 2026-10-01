extends CharacterBody2D

var health: int = 3

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitflash_player: AnimationPlayer = $HitflashPlayer
@onready var timer1: Timer = $Timer1
@onready var timer2: Timer = $Timer2

var projectile = preload("res://assets/scenes/enemies/sand_shifter_projectile.tscn")

func _ready() -> void:
	timer1.start()

func _process(delta: float) -> void:
	if 0 < timer1.time_left and timer1.time_left <= 1:
		animation_player.play("Charge")

# After the first timer ends, Sand Shifter attacks.
func _on_timer_1_timeout() -> void:
	print("Time 1 up, Time 2 start")
	animation_player.play("Attack")
	shoot()
	timer2.start()
	
func _on_timer_2_timeout() -> void:
	print("Time 2 up, Time 1 start")
	animation_player.play("Idle")
	timer1.start()


func shoot() -> void:
	var sand_ball = projectile.instantiate()
	sand_ball.position = global_position + Vector2(0, 15)
	get_parent().call_deferred("add_child", sand_ball)

func _on_damage_area_area_entered(area: Area2D) -> void:
	if area.name == "Attack":
		hitflash_player.play("Hit Flash")
		health -= 1
		if health <= 0:
			queue_free()
			print("Enemy died!")
