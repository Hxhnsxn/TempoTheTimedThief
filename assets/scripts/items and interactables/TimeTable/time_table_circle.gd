extends Control

#==================ROTATE CIRCLE=================================================
# This script has the object rotate in a circular motion and rotate its children
# around it, ensuring the children stay upright.

@export var front_scale: float = 0.8
@export var back_scale: float = 0.4
@export var side_alpha: float = 0.55
@export var tween_time: float = 0.5

@export var offset_degrees: float = 30

@onready var sub_control_folder: Control = $Towers
@onready var texture_rect: TextureRect = $Base

var radius_x: float = 200.0
var radius_y: float = 200.0

var towers: Array[Control] = []
var curr_tower: int = 0
var is_rotating: bool = false

# all scenes - hopefully a better way to grab these
var scene_paths = ["res://assets/scenes/locations/tutorial-the_clock_tower.tscn", 
"res://assets/scenes/locations/demo.tscn"]

func _ready() -> void:
	
	# lock pivot to the center of the viewport
	# you would simply do this for wherever this needs to go!
	var screen_center = get_viewport_rect().size / 2.0
	self.global_position = screen_center
	
	texture_rect.pivot_offset = texture_rect.size * 0.5
	texture_rect.position = -texture_rect.pivot_offset

	var tower_index: int = 0
	# get all tower nodes
	for child in sub_control_folder.get_children():
		if child is Control:
			towers.append(child)
		if child is TextureButton && tower_index < scene_paths.size():
			# assign a scene to switch to for each tower
			var scene_path: String = scene_paths[tower_index]
			tower_index += 1
			child.pressed.connect(_on_tower_pressed.bind(scene_path))
	
	# set radii based on base width / height (with scale!)		
	radius_x = texture_rect.size.x * texture_rect.scale.x / 2
	radius_y = texture_rect.size.y * texture_rect.scale.y / 2
	
	arrange_towers_initially()

# arrange items around the parent's local (0,0) center point once
func arrange_towers_initially() -> void:
	if towers.size() == 0: return
	update_tower_carousel(false)

func _process(_delta: float) -> void:	
	if is_rotating: return
	
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		rotate_towers(int(direction))

func rotate_towers(direction: int) -> void:
	is_rotating = true
	# update current tower index
	curr_tower = (curr_tower - direction + towers.size()) % towers.size()
	update_tower_carousel(true)

func update_tower_carousel(animated: bool) -> void:
	var tween: Tween = null
	if (animated):
		tween = create_tween()
		tween.set_parallel(true)
		
	for i in towers.size():
		var tower = towers[i]
		var offset = _get_wrapped_offset(i - curr_tower)
		var angle = offset * TAU / float(towers.size()) + offset_degrees * PI / 180
		
		var depth = cos(angle)
		var x = sin(angle) * radius_x
		var y = -depth * radius_y
		
		var depth_normalized = inverse_lerp(-1.0, 1.0, depth)
		var scale_value = lerp(back_scale, front_scale, depth_normalized)
		var alpha_value = lerp(side_alpha, 1.0, depth_normalized)
		
		var target_position = size * 0.5 + Vector2(x, y) - tower.size * 0.5
		var target_scale = Vector2.ONE * scale_value
		
		tower.z_index = int(depth_normalized * 100.0)
		tower.disabled = i != curr_tower
		
		if (animated):
			tween.tween_property(tower, "position", target_position, tween_time)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)
			tween.tween_property(tower, "scale", target_scale, tween_time)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)
			tween.tween_property(tower, "modulate:a", alpha_value, tween_time)
		else:
			tower.position = target_position
			tower.scale = target_scale
			tower.modulate.a = alpha_value
	
	if (animated):
		tween.finished.connect(func(): is_rotating = false)

func _get_wrapped_offset(offset: int) -> int:
	var half = floorf(towers.size()) / 2
	if (offset > half):
		offset -= towers.size()
	elif (offset < -half):
		offset += towers.size()
	return offset

# when a tower is pressed, ensure it goes to its corresponding scene
func _on_tower_pressed(target_scene: String) -> void:
	var error = get_tree().change_scene_to_file(target_scene)
	
	if error != OK:
		push_error("Failed to load scene at: " + target_scene)
