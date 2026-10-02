extends Node2D

#================Player SFX================
func play_jump() -> void:
	$SFX/PlayerJump.play()
func play_attack() -> void:
	$SFX/PlayerAttack.play()
