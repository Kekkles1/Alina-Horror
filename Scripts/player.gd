extends CharacterBody3D

const SPEED := 10.0
const MOUSE_SENS := 0.002

@onready var HEAD: Node3D = $Head

var PITCH := 0.0

var FLASHLIGHT_ON:bool = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Left/Right look (Yaw) rotates the body
		rotate_y(-event.relative.x * MOUSE_SENS)

		# Up/Down look (Pitch) rotates the head
		PITCH -= event.relative.y * MOUSE_SENS
		PITCH = clamp(PITCH, deg_to_rad(-89), deg_to_rad(89))
		HEAD.rotation.x = PITCH

	# ESC to release mouse
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event.is_action_pressed("toggle_flashlight"):
		print("Flashlight toggle")
		FLASHLIGHT_ON = !FLASHLIGHT_ON
		$Head/Flashlight/SpotLight3D.visible = FLASHLIGHT_ON

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Movement input
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# IMPORTANT: use global basis so movement follows yaw rotation
	var direction := (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
