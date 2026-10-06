extends CanvasLayer

signal on_transition_finished

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer
@onready var delay = $Timer/delay

func _ready() -> void:
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)
	delay.timeout.connect(_on_timer_timeout)
	
func _on_animation_finished(name):
	if name == "fade_to_black":
		on_transition_finished.emit()
		#The delay allow the player's camera to finish moving
		#before running the transition back to normal
		delay.start(0.5)
		

	elif name == "fade_to_normal":
		color_rect.visible = false
	
func transition():
	color_rect.visible = true
	animation_player.play("fade_to_black")

func _on_timer_timeout():
	animation_player.play("fade_to_normal")
