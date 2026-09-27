extends CharacterBody2D

#============================================================================

var speed = 200.0
var direction: float = 0.0
var curr_health: int

const SLIDESPEED = 500.0		# Sliding movement speed. (Not entirely sure why this has to be set so high to do anything)
const DIVESPEED = 550.0			# Diving movement speed (see above)
const CRAWLSPEED = 120.0		# Crawling movement speed.
const MOVESPEED = 200.0			# Normal movement speed.
const JUMP_VELOCITY = -270.0	# Normal jump velocity.

const ACCEL = 0.15
const FRICTION = 0.3

var is_crouching: bool = false  # Checks if the player is crouching.
var is_attacking: bool = false	# Checks if the player is attacking.
var is_sliding: bool = false    # Checks if the player is sliding.

#@onready var state_machine: StateMachine = $StateMachine

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
#@onready var animation_tree: AnimationTree = $AnimationTree

@onready var coyote_timer: Timer = $Timers/CoyoteTimer
# Variable that checks if coyote time is relevant and available.
var coyote_time_active: bool = false

@onready var walljump_raycast: RayCast2D = $WallJumpRayCast
var walljump_force: float = 500

@onready var uncrouchcheck_raycast: RayCast2D = $UncrouchCheckRayCast

# Reference to hurtboxes.
@onready var hurtbox: CollisionShape2D = $PlayerHurtbox
@onready var crouchhurtbox: CollisionShape2D = $CrouchHurtbox

# References to attack hitbox.
@onready var hitbox: CollisionShape2D = $Attack/AttackHitbox

#============================================================================

func _ready():
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	curr_health = 100
	pass
	
#============================================================================
#============================================================================
#============================================================================

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		is_crouching = false				# Player can't crouch mid-air.
		velocity += get_gravity() * delta	# Apply gravity when airborne.
		# if wall sliding
		if is_on_wall_only() and direction != 0:
			# tweak wall slide speed
			velocity.y = clamp(velocity.y, -99999, 80)
	
	# Get the input direction
	direction = Input.get_axis("move_left", "move_right")
	
	# CROUCH=================================================
	# Toggle for if the player is pressing the crouch input while grounded.
	
	if Input.is_action_just_pressed("crouch"):
		if is_on_floor():
			if direction and (not is_crouching or abs(velocity.x) < CRAWLSPEED + 5.0):
				velocity.x = SLIDESPEED * direction
			is_crouching = true
		else:
			velocity.x = DIVESPEED * direction
			velocity.y = 300
		
	if (
		# to make sliding slower or more committal you could make it so you dont stand up until you reach close to crawlspeed (minor buffers are because of lerp btw)
		not Input.is_action_pressed("crouch")
		and is_on_floor()
		and not uncrouchcheck_raycast.is_colliding()
		and abs(velocity.x) < MOVESPEED
		):
		is_crouching = false
	if is_crouching:
		speed = CRAWLSPEED
		hurtbox.disabled = true
		crouchhurtbox.disabled = false
	else:
		speed = MOVESPEED
		hurtbox.disabled = false
		crouchhurtbox.disabled = true
		
	# Coyote time logic.
	if is_on_floor():
		# If the player is grounded and the coyote time window is active,
		# deactivate the coyote time window.
		if coyote_time_active:
			coyote_time_active = false
			coyote_timer.stop()
	else:
		if not coyote_time_active:
			coyote_time_active = true
			coyote_timer.start()
			
	# JUMP=================================================
	# If the player is attempting to jump, and they are
	# either grounded or the coyote time window is still active,
	# perform a jump.
	if (
		Input.is_action_just_pressed("jump")
		and not is_crouching
		and (!coyote_timer.is_stopped() or is_on_floor())
		):
		velocity.y = JUMP_VELOCITY
		coyote_timer.stop()
		coyote_time_active = true
	# FALL=================================================
	# Allows the player to perform short hops.
	if (
		Input.is_action_just_released("jump") and velocity.y < 0
		):
		velocity.y = JUMP_VELOCITY / 4
	
	#WALL JUMP
	if (
		is_on_wall_only()
		and direction != 0
		and Input.is_action_just_pressed("jump")
		):
		# When raycast scale is -1/1, player is facing left/right.
		# So wall jump should provide a boost in the opposite direction.
		velocity.y = JUMP_VELOCITY
		velocity.x = -(walljump_raycast.scale.x) * walljump_force
	
	
	# ATTACK=================================================
	if (
		# A basic attack.
		# The player needs to not be already attacking,
		# not be crouching, not be airborne,
		# and the cooldown time on the basic attack needs to be finished.
		Input.is_action_pressed("attack")
		and not is_attacking
		and not is_crouching
		and is_on_floor()
		and $Timers/BasicAttackCooldown.time_left <= 0
		):
		is_attacking = true
		animation_player.play("Attack")
	if is_attacking:
		return
	
	# MOVE=================================================
	# handle the movement/deceleration.
	if direction:
		velocity.x = lerp(velocity.x, direction * speed, ACCEL)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION)
	
	# ANIMATIONS=================================================
	# If the player is grounded:
	if is_on_floor():
		# If the player is crouching:
		if is_crouching:
			# If the player is moving while crouching:
			if direction:
				if abs(velocity.x) > CRAWLSPEED + 10.0:
					animation_player.play("Slide")
				else:
					animation_player.play("Crawl")
			else:
				animation_player.play("CrouchBeta")
		# If the player is not crouching:
		else:
			# If the player is moving:
			if direction:
				animation_player.play("Move")
			else:
				animation_player.play("Idle")
	
	#=================================================
	#Moved physics before animation to fix small visual jank
	move_and_slide()
	sprite_flip()
				
	# If the player is airborne:
	if not is_on_floor():
		# if player is moving fast enough to be diving
		if abs(velocity.x) > MOVESPEED + 20:
			animation_player.play("DiveKick")
		# If the player is moving upward:
		elif sign(velocity.y) == -1:
			animation_player.play("Jump")
		# If the player is moving upward:
		else:
			animation_player.play("FallBeta")
	if is_on_wall_only() and velocity.y > 0 and direction != 0:
		animation_player.play("WallSlide")

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area is damageArea:
		take_damage(area.damage, area.global_position, area.knock_force)
	
func take_damage(amount: int, hazard_pos: Vector2, knockback: float) -> void:
	
	curr_health -= amount
	print("Taking damage")
	var knock_dir: Vector2 = (global_position - hazard_pos).normalized()
	velocity = knock_dir * knockback
	if curr_health <= 0:
		die()

func die() -> void:
	queue_free()
	
	
#============================================================================
#============================================================================
#============================================================================

func sprite_flip():
	#animation_tree.set("parameters/Move/blend_position", direction)
	
	# Logic to reverse sprite based on x direction.
	# Tempo's sprites face right by default.
	# Also, this reverse the position of the attack hitbox to match
	# the direction Tempo is facing.
	if direction > 0:
		sprite.flip_h = false
		if sign(hitbox.position.x) == -1:
			hitbox.position.x *= -1
		if sign(walljump_raycast.scale.x) == -1:
			walljump_raycast.scale.x *= -1
	elif direction < 0:
		sprite.flip_h = true
		if sign(hitbox.position.x) == 1:
			hitbox.position.x *= -1
		if sign(walljump_raycast.scale.x) == 1:
			walljump_raycast.scale.x *= -1
		
# After finishing the attack animation, return normal controls.
func _on_animation_player_animation_finished(animation: StringName) -> void:
	if animation == "Attack":
		is_attacking = false
		# When the basic attack cooldown timer is up,
		# the player can perform a basic attack again.
		$Timers/BasicAttackCooldown.start()
