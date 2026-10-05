extends Node


func hitstop(time):
	Engine.time_scale = 0.1
	await get_tree().create_timer(time, true, false, true).timeout
	Engine.time_scale = 1
