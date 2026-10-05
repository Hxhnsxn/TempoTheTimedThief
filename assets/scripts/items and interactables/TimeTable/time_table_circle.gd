extends Control

#==================ROTATE CIRCLE=================================================
# This script has the object rotate in a circular motion and rotate its children
# around it, ensuring the children stay upright.

@export var rotation_speed: float = 0.5
@export var offset_degrees: float = 90

@onready var sub_control_folder: Control = $Towers
@onready var texture_rect: TextureRect = $Base

var radius: float = 200.0

var towers: Array[Control] = []
var curr_tower: int = 0
var is_rotating: bool = false

func _ready() -> void:
	
	# lock pivot to the center of the viewport
	# you would simply do this for wherever this needs to go!
	var screen_center = get_viewport_rect().size / 2.0
	self.global_position = screen_center
	
	# start rotation wherever is desired
	# PI / 2 = the first tower is in front of the screen
	self.rotation = (PI / 2) - deg_to_rad(offset_degrees)
	
	# get all tower nodes
	for child in sub_control_folder.get_children():
		if child is Control:
			towers.append(child)
	
	# set radius based on base width (with scale!)		
	radius = texture_rect.size.x * texture_rect.scale.x / 2
	
	arrange_towers_initially()

# arrange items around the parent's local (0,0) center point once
func arrange_towers_initially() -> void:
	if towers.size() == 0: return
	
	# difference in angle for each tower
	var angle_step = (2 * PI) / towers.size()
	
	for i in range(towers.size()):
		var angle = i * angle_step
		
		# manually force towers to pivot around themselves
		towers[i].pivot_offset = towers[i].size / 2.0
		
		# position the tower based on the rotation + pivot offset (half of tower width / height)
		towers[i].position = Vector2(cos(angle), sin(angle)) * radius - towers[i].pivot_offset

func _process(_delta: float) -> void:	
	# keep all towers upright while the parent rotates 
	for tower in towers:
		tower.rotation = -self.rotation
		
	if is_rotating: return
	
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		rotate_towers(int(direction))

func rotate_towers(direction: int) -> void:
	is_rotating = true
	
	# update current tower index
	curr_tower = (curr_tower - direction + towers.size()) % towers.size()
	
	# calculate amount parent circle has to rotate
	var angle_step = (2 * PI) / towers.size()
	var target_rotation = self.rotation + (direction * angle_step)
	
	# rotate parent circle smoothly via tweening
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(self, "rotation", target_rotation, rotation_speed)
	
	# wait for animation to finish before another rotation
	tween.finished.connect(func(): is_rotating = false)
