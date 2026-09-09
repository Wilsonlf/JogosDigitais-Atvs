extends CharacterBody2D

enum PlayerState {
	walk,
	idle,
	jump,
	duck
}

@onready var sprite: AnimatedSprite2D = $CollisionShape2D/AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var status: PlayerState
var direction: float = 0.0
var jump_count: int = 0
var max_jump_count: int = 2

const SPEED = 80.0
const JUMP_VELOCITY = -300.0

var original_collision_scale: Vector2

func _ready() -> void:
	if collision_shape:
		original_collision_scale = collision_shape.scale
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0

	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.walk:
			walk_state()
		PlayerState.jump:
			jump_state()
		PlayerState.duck:
			duck_state()

	move_and_slide()

func go_to_idle_state() -> void:
	status = PlayerState.idle
	sprite.play("idle")

func go_to_walk_state() -> void:
	status = PlayerState.walk
	sprite.play("walk")

func go_to_jump_state() -> void:
	jump_count += 1
	status = PlayerState.jump
	sprite.play("jump")
	velocity.y = JUMP_VELOCITY

func go_to_duck_state() -> void:
	status = PlayerState.duck
	
	if sprite.sprite_frames.has_animation("duck"):
		sprite.play("duck")
	else:
		sprite.play("idle")
		
	if collision_shape:
		collision_shape.scale.y = original_collision_scale.y * 0.5

func exit_from_duck_state() -> void:
	if collision_shape:
		collision_shape.scale = original_collision_scale


func idle_state() -> void:
	move()

	if Input.is_action_pressed("ui_down"):
		go_to_duck_state()
		return

	if Input.is_action_just_pressed("ui_accept"):
		go_to_jump_state()
		return

	if velocity.x != 0:
		go_to_walk_state()
		return

func walk_state():
	move()

	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		go_to_jump_state()
		return

	if Input.is_action_pressed("duck") or Input.is_action_pressed("ui_down"):
		go_to_duck_state()
		return

	if not is_on_floor():
		status = PlayerState.jump
		sprite.play("jump")
		return

	if velocity.x == 0:
		go_to_idle_state()
		return

func jump_state() -> void:
	move()

	if Input.is_action_just_pressed("ui_accept") and jump_count < max_jump_count:
		go_to_jump_state()
		return

	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

func duck_state() -> void:
	update_direction()
	velocity.x = move_toward(velocity.x, 0, SPEED)

	if not Input.is_action_pressed("ui_down"):
		exit_from_duck_state()
		if direction != 0:
			go_to_walk_state()
		else:
			go_to_idle_state()
		return


func move() -> void:
	update_direction()

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func update_direction() -> void:
	direction = Input.get_axis("ui_left", "ui_right")

	if direction < 0:
		sprite.flip_h = true
	elif direction > 0:
		sprite.flip_h = false
