extends CharacterBody2D

#============================================================================
#==================VARIABLES=================================================
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
# This variable changes based on certain zones. Default 1.
# Ex. A slow zone should have this factor set to 0.5.
var SPEEDFACTOR = 1

var is_crouching: bool = false  # Checks if the player is crouching.
var is_attacking: bool = false	# Checks if the player is attacking.
var is_damaged: bool = false	# Checks if the player is damaged.
var is_sliding: bool = false    # Checks if the player is sliding.
var can_interact: bool = false	# Checks if the player can interact.

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
#================HITFLASH SHADER================
# AnimationPlayer for a shader that indicates a flash of color when
# Tempo takes damage.
@onready var hitflash_player: AnimationPlayer = $HitflashPlayer
#================COYOTE TIME================
@onready var coyote_timer: Timer = $Timers/CoyoteTimer
# Variable that checks if coyote time is relevant and available.
var coyote_time_active: bool = false
#================WALL JUMP================
@onready var walljump_raycast: RayCast2D = $WallJumpRayCast
var walljump_force: float = 500
#================UNCROUCH CHECK================
@onready var uncrouchcheck_raycast: RayCast2D = $UncrouchCheckRayCast
#================COLLISION BOXES================
@onready var collisionbox: CollisionShape2D = $PlayerCollisionBox
@onready var crouchcollisionbox: CollisionShape2D = $CrouchCollisionBox
#================HITBOXES & HURTBOXES================
@onready var hitbox: CollisionShape2D = $Attack/AttackHitbox
@onready var hurtbox: CollisionShape2D = $Hurtbox/PlayerHurtbox
#================VISUAL EFFECTS================
@onready var fx_move :AnimatedSprite2D = $VisualEffects/FX_Move
@onready var fx_slow :AnimatedSprite2D = $VisualEffects/FX_Slow
@onready var fx_wallslide :AnimatedSprite2D = $VisualEffects/FX_WallSlide

#============================================================================
#==================FUNCTIONS=================================================
#============================================================================

#================READY================
func _ready():
	# This helps detect when a player animation finishes.
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	
	# List of visual effects.
	# Certain criteria may change these to true
	# (ex. slow zone sets fx_slow to true upon entering,
	# then back to false upon exiting)
	fx_move.visible = false
	fx_slow.visible = false
	fx_wallslide.visible = false
	curr_health = 100
	
#================PHYSICS PROCESS================
func _physics_process(delta: float) -> void:
	
	# Gravity and wall slide.
	if not is_on_floor():
		is_crouching = false				
		velocity += get_gravity() * delta
		# if wall sliding
		if is_on_wall_only() and direction != 0:
			# tweak wall slide speed
			fx_wallslide.play()
			fx_wallslide.visible = true
			velocity.y = clamp(velocity.y, -99999, 80)
	if not is_on_wall_only():
		fx_wallslide.stop()
		fx_wallslide.visible = false

#================CROUCH================
	# The player can only crouch while grounded.
	if Input.is_action_just_pressed("crouch"):
		if is_on_floor():
			is_crouching = true
		
	if (
		# to make sliding slower or more committal you
		# could make it so you dont stand up until you reach
		# close to crawlspeed (minor buffers are because of lerp btw)
		not Input.is_action_pressed("crouch")
		and is_on_floor()
		and not uncrouchcheck_raycast.is_colliding()
		and abs(velocity.x) < MOVESPEED
		):
		is_crouching = false
	if is_crouching:
		speed = CRAWLSPEED * SPEEDFACTOR
		collisionbox.disabled = true
		crouchcollisionbox.disabled = false	
	else:
		speed = MOVESPEED * SPEEDFACTOR
		collisionbox.disabled = false
		crouchcollisionbox.disabled = true
		
#================JUMP================
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
		AudioManager.play_jump()
	#slide controls
	if Input.is_action_just_pressed("jump") and is_crouching:
		if direction and abs(velocity.x) < CRAWLSPEED + 5.0:
			velocity.x = SLIDESPEED * direction
		
#================FALL================
	# Allows the player to perform short hops.
	if (
		Input.is_action_just_released("jump") and velocity.y < 0
		):
		velocity.y = JUMP_VELOCITY / 4
	
#================WALL JUMP================
# Only trigger when an x-direction is being held.
	if (
		is_on_wall_only()
		and direction != 0
		and Input.is_action_just_pressed("jump")
		):
		# When raycast scale is -1/1, player is facing left/right.
		# So wall jump should provide a boost in the opposite direction.
		velocity.y = JUMP_VELOCITY
		velocity.x = -(walljump_raycast.scale.x) * walljump_force
	
#================COYOTE TIME================
# If the player is grounded and the coyote time window is active,
# deactivate the coyote time window.
	if is_on_floor():
		if coyote_time_active:
			coyote_time_active = false
			coyote_timer.stop()
	else:
		if not coyote_time_active:
			coyote_time_active = true
			coyote_timer.start()

#================BASIC ATTACK================
# A basic attack.
# The player needs to not be already attacking,
# not be crouching, not be airborne,
# and the cooldown time on the basic attack needs to be finished.
	if (
		Input.is_action_just_pressed("attack")
		and not is_attacking
		and not is_crouching
		and is_on_floor()
		and $Timers/BasicAttackCooldown.time_left <= 0
		):
		is_attacking = true
		animation_player.play("Attack")
		AudioManager.play_attack()
	#divekick code
	if Input.is_action_just_pressed("attack") and not is_on_floor() and direction != 0:
		velocity.x = DIVESPEED * direction
		velocity.y = 300
		animation_player.play("DiveKick")
	# This line prevents the attack animation from being
	# interrupted by anything else.
	if is_attacking:
		return
	
#================MOVE================
# Input direction.
	direction = Input.get_axis("move_left", "move_right")
	
	# Handle the movement/deceleration.
	if direction:
		velocity.x = lerp(velocity.x, direction * speed, ACCEL)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION)
	
#================ANIMATIONS================
	# If the player is grounded:
	if is_on_floor():
		# If the player is crouching:
		if is_crouching:
			fx_move.visible = false
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
				fx_move.visible = true
			else:
				animation_player.play("Idle")
				fx_move.visible = false
	
	#=================================================
	# Moved physics before animation to fix small visual jank
	move_and_slide()
	sprite_flip()
				
	# If the player is airborne:
	if not is_on_floor():
		fx_move.visible = false
		# if animation is flip animation keep doing that
		if animation_player.current_animation == "Flip":
			pass
		# if player is moving fast enough to be diving
		elif abs(velocity.x) > MOVESPEED + 20:
			animation_player.play("DiveKick")
		# If the player is moving upward:
		elif sign(velocity.y) == -1:
			animation_player.play("Jump")
		# If the player is moving upward:
		else:
			animation_player.play("FallBeta")
	if is_on_wall_only() and velocity.y > 0 and direction != 0:
		animation_player.play("WallSlide")
	if animation_player.current_animation != "DiveKick":
		$DiveKick/DiveHitbox.disabled = true
		
#================PROCESS================
func _process(delta: float) -> void:
	# When the invulnerability period after taking damage has finished
	# (ex. the timer for it is up), restore hurtbox.
	if $Timers/HurtCooldown.time_left > 0:
		hurtbox.disabled = true
	else:
		hurtbox.disabled = false

#================SPRITE FLIP================
# Logic to reverse sprites, some VFX and hitboxes based on x direction.
# Tempo's sprites face right by default.
func sprite_flip():
	if direction > 0:
		sprite.flip_h = false
		fx_move.flip_h = false
		fx_wallslide.flip_h = false
		if sign(hitbox.position.x) == -1:
			hitbox.position.x *= -1
		if sign($DiveKick/DiveHitbox.position.x) == -1:
			$DiveKick/DiveHitbox.position.x *= -1
		if sign(walljump_raycast.scale.x) == -1:
			walljump_raycast.scale.x *= -1
	elif direction < 0:
		sprite.flip_h = true
		fx_move.flip_h = true
		fx_wallslide.flip_h = true
		if sign(hitbox.position.x) == 1:
			hitbox.position.x *= -1
		if sign($DiveKick/DiveHitbox.position.x) == 1:
			$DiveKick/DiveHitbox.position.x *= -1
		if sign(walljump_raycast.scale.x) == 1:
			walljump_raycast.scale.x *= -1
		
#================FINISH ANIMATION================
# After finishing an attack animation, return normal controls.
func _on_animation_player_animation_finished(animation: StringName) -> void:
	if animation == "Attack":
		is_attacking = false
		# When the basic attack cooldown timer is up,
		# the player can perform a basic attack again.
		$Timers/BasicAttackCooldown.start()
		
#================SLOW ZONE================
# Upon entering a slow zone hazard, Tempo's movement speeed should be
# decreased. Upon exiting, return to normal.
func enter_slow_zone() -> void:
	SPEEDFACTOR = 0.35
	fx_slow.visible = true
func exit_slow_zone() -> void:	
	SPEEDFACTOR = 1
	fx_slow.visible = false

func dive_bounce():
	velocity.y = -300
	$Timers/HurtCooldown.start(1)
	$AnimationPlayer.play("Flip")

#================DAMAGE COLLISION================
# When an enemy/hazard attack hitbox enters Tempo's hurtbox,
# Tempo's timer loses seconds,
# and he gets knocked back a bit.
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is damageArea:
		if hurtbox.disabled == false:
			take_damage(area.damage, area.global_position, area.knock_force)
	
func take_damage(amount: int, hazard_pos: Vector2, knockback: float) -> void:
	curr_health -= amount
	
	
	
	# If the attack causes Tempo's timer to reach 0, death is imminent.
	if curr_health <= 0:
		die()
	# Otherwise, knock Tempo back and start a timer.
	# Tempo will have invincibility frames that disable his hurtbox.
	# Then, when the timer is finished, restore Tempo's hurtbox.
	else:
		var knock_dir: Vector2 = (global_position - hazard_pos).normalized()
		velocity = knock_dir * knockback
		
		hitflash_player.play("Hit Flash")
		
		$Timers/HurtCooldown.start(2)
		
#================DEATH================
func die() -> void:
	queue_free()
