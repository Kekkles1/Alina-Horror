extends CharacterBody3D

const WALK_SPEED := 3.0
const RUN_SPEED := 10.0
const CROUCH_SPEED := 1.0

const CROUCH_DEPTH := -0.5
const MOUSE_SENS := 0.002

@onready var HEAD: Node3D = $Head

var PITCH := 0.0
var current_speed = WALK_SPEED
var lerp_speed = 10.0
# by default you are walking
var RUN_ON: bool = false
# by default you are not crouching
var CROUCH_ON: bool = false
# by default flashlight is on
var FLASHLIGHT_ON: bool = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENS)

		PITCH -= event.relative.y * MOUSE_SENS
		PITCH = clamp(PITCH, deg_to_rad(-89), deg_to_rad(89))
		HEAD.rotation.x = PITCH

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event.is_action_pressed("toggle_run"):
		RUN_ON = !RUN_ON
		print("RUN:", RUN_ON)
		
	if event.is_action_pressed("toggle_flashlight"):
		FLASHLIGHT_ON = !FLASHLIGHT_ON
		$Head/Flashlight/SpotLight3D.visible = FLASHLIGHT_ON

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if Input.is_action_pressed("toggle_crouch"):
		current_speed = CROUCH_SPEED
		HEAD.position.y = lerp(HEAD.position.y,1.8+CROUCH_DEPTH,delta*lerp_speed)
		CROUCH_ON = !CROUCH_ON
	else:
		HEAD.position.y = lerp(HEAD.position.y,1.8,delta*lerp_speed)
		
	var current_speed := RUN_SPEED if RUN_ON else WALK_SPEED

	if direction != Vector3.ZERO:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
