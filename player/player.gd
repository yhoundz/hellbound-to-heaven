extends CharacterBody2D
class_name Player

enum STATE {
	IDLE,
	WALKING,
	CHARGING,
	JUMPING,
	FALLING,
	WALL_BOUNCE
	}

@export var speed: int = 55
@export var jump_speed: int = -140
@export var acceleration: int = 30
@export var friction: int = 40
@export var curr_state: STATE = STATE.IDLE

@onready var jump_timer: Timer = $jump_timer
@onready var sfx_jump: AudioStreamPlayer2D = $sfx_jump
@onready var sfx_walk = $sfx_walk
@onready var sfx_land_bounce = $sfx_land_bounce
@onready var sfx_charge = $sfx_charge

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var fall_gravity: int = int(gravity * 1.3)
var direction: float = 0.0
var just_jumped: bool = false
var height_add: int = 0
var jump_vector_x: int = 0
var velocity_modifier: int = 0
var sfx_just_played: bool = false

signal hitboxDirection(rp)

func _ready() -> void:
	jump_timer.start()
	jump_timer.set_paused(true)
	set_slide_on_ceiling_enabled(false)

func _physics_process(delta: float) -> void:
	
	if curr_state != STATE.FALLING:
		velocity.y += gravity * delta
		
	else:
		velocity.y += fall_gravity * delta
	get_input(delta)
	move_and_slide()
	#print(get_real_velocity().x)

func get_input(delta: float) -> void:
	direction = Input.get_axis("ui_left", "ui_right")
	#print(direction)
	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
		
	if direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
	#print(STATE.keys()[curr_state])
	compute_slide()
	match curr_state:
		STATE.IDLE:
			act_idle(delta)
			get_node("AnimatedSprite2D").play("idle")
		STATE.WALKING:
			act_walk(delta)
			get_node("AnimatedSprite2D").play("run")
		STATE.CHARGING:
			act_charge()
			get_node("AnimatedSprite2D").play("hold")
		STATE.JUMPING:
			act_jump(delta)
			get_node("AnimatedSprite2D").play("jump")
		STATE.FALLING:
			act_fall()
			get_node("AnimatedSprite2D").play("falling")
		STATE.WALL_BOUNCE:
			act_wall_bounce()
			get_node("AnimatedSprite2D").play("falling")

func compute_slide() -> bool:
	if get_slide_collision_count() > 0 and rad_to_deg(get_floor_angle()) > 40:
		set_floor_max_angle(deg_to_rad(40))
		return true
	else:
		set_floor_max_angle(deg_to_rad(45))
		return false

func act_idle(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0
		if direction == -1:
			get_node("AnimatedSprite2D").flip_h = true
		if direction == 1:
			get_node("AnimatedSprite2D").flip_h = false
		if direction:
			curr_state = STATE.WALKING
		else:
			velocity.x = lerp(velocity.x, float(), friction * delta)
		if Input.is_action_just_pressed("ui_accept"):
				curr_state = STATE.CHARGING
	if velocity.y > 0:
		curr_state = STATE.FALLING

func act_walk(delta: float) -> void:
	if not sfx_just_played:
		sfx_walk.play()
		sfx_just_played = true
	if is_on_floor():
		velocity.y = 0
		if direction == -1:
			get_node("AnimatedSprite2D").flip_h = true
		if direction == 1:
			get_node("AnimatedSprite2D").flip_h = false
		if direction:
			velocity.x = lerp(velocity.x, direction * speed, acceleration * delta)
		else:
			sfx_just_played = false
			sfx_walk.stop()
			curr_state = STATE.IDLE
		if Input.is_action_just_pressed("ui_accept"):
			sfx_walk.stop()
			sfx_just_played = false
			curr_state = STATE.CHARGING
	if velocity.y > 0:
		sfx_just_played = false
		curr_state = STATE.FALLING

func act_charge() -> void:
	if not sfx_just_played:
		sfx_charge.play()
		sfx_just_played = true
	velocity.x = 0
	if Input.is_action_just_released("ui_accept") and is_on_floor():
		sfx_just_played = false
		curr_state = STATE.JUMPING
	charge_jump()

func act_jump(delta: float) -> void:
	if not sfx_just_played:
		sfx_jump.play()
		sfx_just_played = true
	if not just_jumped:
		try_jump(direction, delta)
		just_jumped = true
	if is_on_ceiling_only():
		velocity.y = 0
		if not sfx_just_played:
			sfx_jump.play()
			sfx_just_played = true
		sfx_just_played = false
		curr_state = STATE.FALLING
	if velocity.y > 0 and just_jumped:
		sfx_just_played = false
		curr_state = STATE.FALLING
	else:
		if is_on_wall_only():
			var bounce_velocity: int = -jump_vector_x
			bounce_velocity *= 0.6 * (get_real_velocity().y/(jump_speed - height_add))
			velocity.x = bounce_velocity
			sfx_just_played = false
			curr_state = STATE.WALL_BOUNCE

func act_fall() -> void:
	just_jumped = false
	if is_on_floor():
		if not sfx_just_played:
			sfx_land_bounce.play()
			sfx_just_played = false
		curr_state = STATE.IDLE
	else:
		if is_on_wall_only():
			var bounce_velocity: int = -jump_vector_x
			bounce_velocity *= 0.6 * (-get_real_velocity().y/(jump_speed - height_add))
			velocity.x = bounce_velocity
			sfx_just_played = false
			curr_state = STATE.WALL_BOUNCE

func act_wall_bounce():
	if not sfx_just_played:
		sfx_land_bounce.play()
		sfx_just_played = true
	if is_on_floor():
		velocity.x = 0
		sfx_just_played = false
		curr_state = STATE.IDLE
	if velocity.y > 0:
		sfx_just_played = false
		curr_state = STATE.FALLING

func charge_jump() -> void:
	if jump_timer.is_paused():
		jump_timer.set_paused(false)
		jump_timer.start()

func try_jump(direction: float, delta: float) -> void:
	jump_timer.set_paused(true)
	
	jump_vector_x = int(150 * direction)
	height_add = int(340 * (jump_timer.wait_time - jump_timer.time_left))
	velocity.y = jump_speed - height_add
	velocity.x = jump_vector_x

func _on_jump_timer_timeout() -> void:
	if curr_state == STATE.CHARGING:
		curr_state = STATE.JUMPING
