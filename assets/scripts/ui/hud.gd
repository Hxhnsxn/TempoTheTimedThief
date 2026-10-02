extends Control


#================TREASURE================
# Permanent treasure count.
var held_treasure: int = 0		
# Holds a temporary amount of treasure that is accrued
# per level. If the player completes the level, this value is added
# to held_treasure.
var temp_treasure: int = 0		
var max_treasure: int = 999999
@onready var treasure_label: Label = $VBoxContainer/Treasure/TreasureLabel
#================KEYS================
var keys: int = 0
@onready var keys_label: Label = $VBoxContainer/Keys/KeysLabel
#================ARTIFACTS================
# A dictionary of artifacts that can be found in levels.
var artifacts = {
	"Artifact 1": false,
	"Artifact 2": false,
	"Artifact 3": false
}

func _process(delta: float) -> void:
	treasure_label.text = str(temp_treasure)
	keys_label.text = str(keys)
